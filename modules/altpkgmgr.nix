{ config, pkgs, ... }:

{
  config = {
    programs.appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [ pkgs.xorg.libxshmfence ];
      };
    };
  services.flatpak.enable = true;
  environment.systemPackages = with pkgs; [
    appimage-run
   ];
  };
}

