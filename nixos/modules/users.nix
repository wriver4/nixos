{ config, pkgs, ... }:

{
  config = {
    users.defaultUserShell = pkgs.zsh;
    users.users.mark = {
      isNormalUser = true;
      description = "mark";
      extraGroups = [ "wheel" "networkmanager" "systemd-journal" "libvirtd" "docker" "www-data"]; # "vbox" "vboxusers"
      openssh.authorizedKeys.keys = [
        #  Your public key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtBZ5F327lNczQ76KxK1ibJ8wl/cMh1R8DvZh/uB3LP mark@king"
      ];    
    packages = with pkgs; [];
    };
  };
}