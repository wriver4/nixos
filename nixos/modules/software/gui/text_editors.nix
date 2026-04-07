{ config, pkgs, ... }:

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
    ];
  };
}
