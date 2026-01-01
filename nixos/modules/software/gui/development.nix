{ config, pkgs, ... }:
let
  n8nDesktopItem = pkgs.makeDesktopItem {
    name = "n8n-launcher";
    desktopName = "n8n Workflow Automation";
    exec = "${pkgs.n8n}/bin/n8n"; # Ensure n8n is available in pkgs
    icon = "n8n";
    type = "Application";
    categories = [ "Development" "Utility" ];
  };
in
{
  config = {
    environment.systemPackages = with pkgs; [
      terminator
      kdiff3
      unstable.vscode
      code-nautilus
      figma-linux
      filezilla
      libfilezilla
      #mailcatcher
      sqlitebrowser
      dbeaver-bin
      #pgadmin4
      httrack
      # flatpack-builder
      # unstable.node-red
      unstable.bcompare
      unstable.emcee
      postman
      # d2
      # lunacy
      electron
      uv
      unstable.n8n
      n8nDesktopItem
      playwright-test
      jetbrains.pycharm-oss
      jetbrains-toolbox
      android-studio
      eclipses.eclipse-jee
      docker-compose
    ];
  };
}
