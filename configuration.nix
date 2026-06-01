{ config, pkgs, lib, inputs, nixpkgs-unstable, ... }:

{

  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import nixpkgs-unstable {
      system = pkgs.stdenv.hostPlatform.system;
      config = config.nixpkgs.config;
    };
  };

 
  nix.settings = {
    download-buffer-size = 1048576000; # 1000 MiB
    substituters = [
      "# <your-nix-cache-url>"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "<your-cache-public-key>"
      "<your-cache-public-key-2>"
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };


  # Allow the weaver service user to traverse into mark's home to read the
  # anvil inventory file. 0711 = owner rwx, group --x, world --x (traversable,
  # not listable). Combined with weaver's "users" group membership (Projects is 750).
  # Activation script is more reliable than tmpfiles z-rule for existing dirs.
  system.activationScripts.weaverHomeAccess = "chmod 711 /home/mark";

  # Weaver
  services.weaver.enable = true;
  # Sops-nix: derive age decryption key from the host SSH ed25519 key
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Engram secrets -- edit with: sudo sops-edit /etc/nixos/secrets/engram.yaml
  sops.secrets."engram-pg-password"     = { sopsFile = ./secrets/engram.yaml; };
  sops.secrets."engram-cognee-password" = { sopsFile = ./secrets/engram.yaml; };

  # Engram connection config for the Weaver service
  services.weaver.engram = {
    pgPasswordFile       = config.sops.secrets."engram-pg-password".path;
    cogneeEmail          = "weaver@weaver.dev";
    cogneePasswordFile   = config.sops.secrets."engram-cognee-password".path;
    hostsInventoryPath   = "<your-inventory-path>";
  };

  
  # Cache management
  services.cache-cap = {
    enable = true;
    interval = "daily";
    targets = [
      { path = "/home/mark/.cache";          maxSize = "4G"; user = "mark"; }
      { path = "/home/mark/.cache/mozilla";  maxSize = "1G"; user = "mark"; }
      { path = "/home/mark/.cache/BraveSoftware"; maxSize = "1G"; user = "mark"; }
      { path = "/var/cache";                 maxSize = "2G"; }
    ];
  };


  # Enable automatic optimization of the Nix store

  imports = [
    ./hardware-configuration.nix
    ./modules/common.nix
    ./modules/hosts/king.nix
    ./modules/shell.nix
    ./modules/users.nix
    ./modules/git.nix
    ./modules/services/cache-cap.nix
    ./modules/services/cockpit.nix
    #./modules/services/n8n.nix
    ./modules/services/mkcert-bootstrap.nix
    ./modules/services/oracle.nix
    ./modules/services/php.nix
    ./modules/services/postfix.nix
    ./modules/services/security.nix
    ./modules/services/servers.nix
    ./modules/services/maintenance.nix
    ./modules/services/webserver.nix
    ./modules/services/weaver-codebase-mcp.nix
    ./modules/system/pki.nix
    ./modules/virtualization.nix
    ./modules/altpkgmgr.nix
    ./modules/software/gui
    ./modules/software/cli
    ./modules/gnome.nix
    # <home-manager/nixos>
  ];

  # try to keep google chrome from shutting down vscode
  systemd.user.services."app@autostart".serviceConfig = {
    MemoryHigh = "80%";
    MemoryMax = "90%";
  };


  environment.systemPackages = with pkgs; [
    appimage-run
    (pkgs.symlinkJoin {
      name = "claude-desktop-wayland";
      paths = [ inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs ];
      buildInputs = [ pkgs.makeWrapper pkgs.asar pkgs.python3 ];
      postBuild = ''
        # Electron 41+ uses "desktopName" in package.json inside app.asar for Wayland app_id.
        # CHROME_DESKTOP is ignored. We patch the asar and inject it via bwrap --ro-bind.
        wrapProgram $out/bin/claude-desktop \
          --set CHROME_DESKTOP claude.desktop

        # Trace the wrapper chain to find the original asar path.
        # Nix store paths are /nix/store/{hash}-{name} — no slash before the name.
        INIT_SCRIPT=$(grep -o '/nix/store/[^ ]*claude-desktop-init' "$out/bin/.claude-desktop-wrapped" | head -1)
        INNER_BIN=$(grep -o '/nix/store/[^ ]*/bin/claude-desktop' "$INIT_SCRIPT" | head -1)
        ORIG_ASAR="''${INNER_BIN%/bin/claude-desktop}/lib/claude-desktop/app.asar"

        # Extract asar, add desktopName to package.json, repack
        WORK=$(mktemp -d)
        asar extract "$ORIG_ASAR" "$WORK/extracted"
        python3 -c "
import json
path = '$WORK/extracted/package.json'
with open(path) as f: pkg = json.load(f)
pkg['desktopName'] = 'claude.desktop'
with open(path, 'w') as f: json.dump(pkg, f)
"
        mkdir -p "$out/lib-patched"
        asar pack "$WORK/extracted" "$out/lib-patched/app.asar"
        rm -rf "$WORK"

        # Inject --ro-bind before the final exec line in .claude-desktop-wrapped.
        # The file is a symlink to the read-only nix store; unlink it first so we
        # can create a real writable file at the same path.
        PATCHED="$out/lib-patched/app.asar"
        python3 -c "
import os
wrapped = '$out/bin/.claude-desktop-wrapped'
patched = '$PATCHED'
orig = '$ORIG_ASAR'
with open(wrapped) as f:
    content = f.read()
lines = content.split('\n')
# Insert --ro-bind BEFORE container-init so it is a bwrap option, not an argument to the init binary
for i in range(len(lines) - 1, -1, -1):
    if 'container-init' in lines[i] and not lines[i].strip().startswith('#'):
        lines.insert(i, '  --ro-bind \"%s\" \"%s\"' % (patched, orig))
        break
os.unlink(wrapped)
with open(wrapped, 'w') as f:
    f.write('\n'.join(lines))
os.chmod(wrapped, 0o755)
"

        rm $out/share/applications/claude.desktop
        cat > $out/share/applications/claude.desktop << EOF
[Desktop Entry]
Categories=Office;Utility
Exec=env NIXOS_OZONE_WL=1 CHROME_DESKTOP=claude.desktop claude-desktop --enable-features=WaylandWindowDecorations --start-maximized %u
GenericName=Claude Desktop
Icon=claude
MimeType=x-scheme-handler/claude
Name=Claude
StartupNotify=true
StartupWMClass=claude
Terminal=false
Type=Application
Version=1.5
EOF
      '';
    })
  ];

  # dynamic linking programs
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glib
    nss
    nspr
    dbus
    atk
    cups
    libdrm
    gtk3
    pango
    cairo
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    mesa
    expat
    xorg.libxcb
    libxkbcommon
    alsa-lib
    # Wayland
    wayland
    libGL
    libglvnd
    libgbm
  ];
 
  environment = {
  sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
XDG_DATA_DIRS = [ "$HOME/.nix-profile/share" ];
    PATH = [ "$HOME/.local/bin" ];
  };
  variables.ELECTRON_RUN_AS_NODE = lib.mkForce "";
};
 
  # Ensure proper desktop integration
  xdg = {
    portal.enable = true;
    mime.enable = true;
    icons.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
