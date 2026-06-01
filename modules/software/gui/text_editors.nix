{ config, pkgs, ... }:

let
  vivifyDesktop = pkgs.makeDesktopItem {
    name = "vivify";
    desktopName = "Vivify";
    comment = "View Markdown and Jupyter Notebooks in the browser";
    exec = "viv %f";
    mimeTypes = [
      "text/markdown"
      "text/x-markdown"
      "application/x-ipynb+json"
    ];
    categories = [ "Utility" "TextEditor" "Viewer" ];
    noDisplay = false;
  };
in
{
  config = {
    environment.systemPackages = with pkgs; [
      libreoffice-fresh
      hunspell # spell checker for libreoffice
      geany
      # unstable.marktext
      unstable.kdePackages.ghostwriter # markdown editor
      #stirling-pdf
      zettlr
      vivify # Markdown/Jupyter viewer in the browser
      vivifyDesktop
    ];
  };
}
