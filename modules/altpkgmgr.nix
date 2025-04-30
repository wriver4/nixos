{ config, pkgs, ... }:

{
  config = {
    programs.appimage = {
      enable = true;
      binfmt = true;
   };
  services.flatpak.enable = true;
  environment.systemPackages = with pkgs; [
   appimage-run
  ];

  };
}

