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
  };

  # Enable automatic optimization of the Nix store
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;

  imports = [
    ./hardware-configuration.nix
    ./modules/common.nix
    ./modules/hosts/king.nix
    ./modules/shell.nix
    ./modules/users.nix
    ./modules/git.nix
    ./modules/services/security.nix
    ./modules/services/servers.nix
    ./modules/services/php.nix
    ./modules/services/webserver.nix
    ./modules/services/n8n.nix
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
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        # Modify the desktop file to add Wayland window decorations
        # This enables GNOME top bar menu controls (minimize/maximize/close)
        rm $out/share/applications/claude.desktop
        cat > $out/share/applications/claude.desktop << EOF
[Desktop Entry]
Categories=Office;Utility
Exec=claude-desktop --enable-features=WaylandWindowDecorations %u
GenericName=Claude Desktop
Icon=claude
MimeType=x-scheme-handler/claude
Name=Claude
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

  environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  environment.variables.ELECTRON_RUN_AS_NODE = lib.mkForce "";


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
