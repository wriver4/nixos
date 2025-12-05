{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      libreoffice-fresh
      hunspell # spell checker for libreoffice
      geany
      marktext
      kdePackages.ghostwriter # markdown editor
      #stirling-pdf
    ];
  };
}
