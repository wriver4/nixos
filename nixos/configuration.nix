{ config, pkgs, lib, inputs, ... }:

{
  
  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import <unstable> {
      config = config.nixpkgs.config;
    };
  };

  nix.settings = {
    download-buffer-size = 524288000; # 500 MiB
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

  # Install via AppImage
  environment.systemPackages = with pkgs; [
    appimage-run
  ];

  # dynamic linking programs
  programs.nix-ld.enable = true;

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
