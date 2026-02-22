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
      obs-studio
      krita
      gimp
      unstable.inkscape-with-extensions
      imagemagick # image manipulation
      cobang  # qrcode scanner
      scantailor-universal
      # drawing
      drawio

      # video editing (installed via flatpak)
      lightworksDesktop

      # LaTeX (needed by Zettlr for PDF export via Pandoc/XeLaTeX)
      texlive.combined.scheme-medium
    ];
  };
}
