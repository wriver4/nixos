{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      vlc
      spotify
      shotcut
      simplescreenrecorder
      krita
      gimp
      obs-studio
      imagemagick # image manipulation
      cobang  # qrcode scanner

      # drawing
      drawio
    ];
  };
}
