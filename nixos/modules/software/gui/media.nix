{ config, pkgs, ... }:

let
  lightworksDesktop = pkgs.makeDesktopItem {
    name = "lightworks";
    desktopName = "Lightworks";
    comment = "Cross-platform film & video editor";
    exec = "flatpak run com.lwks.Lightworks";
    icon = "com.lwks.Lightworks";
    terminal = false;
    categories = [ "AudioVideo" "AudioVideoEditing" ];
  };
in
{
  config = {
    environment.systemPackages = with pkgs; [
      vlc
      spotify
      shotcut
      simplescreenrecorder
      krita
      gimp
      unstable.inkscape-with-extensions
      # gpustat
      # gpu-screen-recorder-gtk
      # gpu-screen-recorder-ui #replacement for gtk not packaged yet
      imagemagick # image manipulation
      cobang  # qrcode scanner

      # drawing
      drawio

      # video editing (installed via flatpak)
      lightworksDesktop
    ];
  };
}
