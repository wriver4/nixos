{ config, pkgs, lib, ... }:



{
  config = {

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  programs.seahorse.enable = true;
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "terminator";
  };
    
  environment.systemPackages = with pkgs; [
    
    brasero
    gnome-builder
    gnome-usage
    cheese
    dconf-editor
    gnome-tweaks
    # gnomeExtensions.gsconnect
    gnomeExtensions.force-quit
    # gnomeExtensions.systemd-manager
    # gnomeExtensions.window-state-manager
    # gnomeExtensions.serenity-desktop # may conflict with window-state-manager
    # gnomeExtensions.rdesktop-launcher
    gnomeExtensions.public-ip-address
    nautilus-python
    nautilus-open-any-terminal
  ];
  #exclude some Gnome Packages
  environment.gnome.excludePackages = with pkgs;[
    geary # email
    epiphany # web browser
    gnome-maps
    gnome-weather
    gnome-tour
  ];


  #fontDir.enable = true;
  fonts.packages = with pkgs; [
    corefonts
    dejavu_fonts
    freefont_ttf
    google-fonts
    inconsolata
    liberation_ttf
    ubuntu_font_family
  ];
  

  };
}