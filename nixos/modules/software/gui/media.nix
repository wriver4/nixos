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
      # gpustat
      # gpu-screen-recorder-gtk
      # gpu-screen-recorder-ui #replacement for gtk not packaged yet
      imagemagick # image manipulation
      cobang  # qrcode scanner

      # drawing
      drawio
    ];
  };
}
