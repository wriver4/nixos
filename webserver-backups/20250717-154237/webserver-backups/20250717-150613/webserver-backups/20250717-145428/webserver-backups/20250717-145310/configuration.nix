{ config, pkgs, lib, inputs,  ... }:
  imports = [
    ./webserver.nix
  ];

 
{
nix.settings = {
  download-buffer-size = 524288000; # 500 MiB
};

  imports =
    [ ./hardware-configuration.nix
      ./modules/common.nix
      ./modules/hosts/king.nix
      ./modules/shell.nix
      ./modules/users.nix
      ./modules/git.nix
      ./modules/services/servers.nix
      ./modules/services/php.nix
      ./modules/virtualization.nix
      ./modules/altpkgmgr.nix
      ./modules/software/gui.nix
      ./modules/gnome.nix
      # <home-manager/nixos>
    ];

  # environment.systemPackages = with pkgs; [ ];
    


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
