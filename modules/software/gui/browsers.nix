{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      unstable.firefox
      vivaldi
      google-chrome
      brave
      chromium
      # browsers # I am not ready yet
      # opera due to lack of support
      element-web
      # vdhcoapp
    ];
  };
}
