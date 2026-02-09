{ config, pkgs, ... }:
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
      pgadmin4
      unstable.dbvisualizer
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
      playwright-test
      jetbrains.pycharm-oss
      jetbrains-toolbox
      android-studio
      # eclipses.eclipse-jee
      docker-compose
      javaPackages.compiler.temurin-bin.jre-25
      #or
      # javaPackages.compiler.openjdk25
    ];
  };
}
