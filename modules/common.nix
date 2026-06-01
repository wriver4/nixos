{ config, pkgs, lib, inputs, ... }:

{

imports = [
   ./software/cli
   ./services/llama-embed.nix
   ./services/llama-gen.nix
   ./services/engram-memory.nix
   ./services/engram-graph-ui.nix
   ./services/engram-ui.nix
   ./services/engram-query.nix
   # still want nh namual for now
   #./services/nix.nix
   # ./backup.nix
];


config = {
  # Expiremental Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  programs.nano.nanorc = ''
    set nowrap
    set tabstospaces
    set tabsize 2
    '';

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
      #UseDns = true;
    };
    openFirewall = true;
  };

  # List services that you want to enable:



  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.journald.extraConfig = ''
    SystemMaxUse=2G
    MaxRetentionSec=1month
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  environment.systemPackages = with pkgs; [
    _1password-cli # 1Password CLI
    openssl # A toolkit for the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols
    wget # A network utility to retrieve files from the Web
    tailscale # Tailscale is a mesh VPN that makes it easy to connect your devices, wherever they are.
    unstable.nh # nix cli helper
    nix-output-monitor # Monitor Nix builds
    nixos-generators # Generate NixOS configurations
    unstable.cockpit # Web-based interface for system administration
    clamav # Antivirus engine for detecting trojans, viruses, malware & other malicious threats
    vulnix # Nixpkgs vulnerability scanner
    nodejs_24 # Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine
    sops # Secrets OPerationS — edit sops-encrypted secret files
    ssh-to-age # Derive age keys from SSH ed25519 keys (needed to decrypt sops files manually)
    # sops-edit wrapper: derives age key from SSH host key so sudo sops-edit <file> just works
    (pkgs.writeShellScriptBin "sops-edit" ''
      tmp=$(mktemp /tmp/age-XXXXXX.key)
      ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key < /etc/ssh/ssh_host_ed25519_key > "$tmp" 2>/dev/null
      SOPS_AGE_KEY_FILE="$tmp" ${pkgs.sops}/bin/sops "$@"
      rm -f "$tmp"
    '')
  ];


  services.cockpit.settings.WebService.Origins = lib.mkForce "http://localhost:9090 https://localhost:9090";
  services.cockpit = {
    enable = true;
    openFirewall = true;
      settings = {
        WebService = {
         AllowUnencrypted = true;
        };
      };
    };
  };
}
