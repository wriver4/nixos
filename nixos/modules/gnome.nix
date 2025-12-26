{ config, pkgs, lib, ... }:



{
  config = {

    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.desktopManager.gnome.extraGSettingsOverridePackages = with pkgs; [
      nautilus
      #gnome.mutter # should not be needed
      gtk4 # should not be needed
    ];


    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;

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
      wl-clipboard
      wl-clipboard-x11
      xclip
      xsel
      gnome-extension-manager
      gnomeExtensions.tophat
      gnomeExtensions.force-quit
      gnomeExtensions.dash-to-dock
      gnomeExtensions.hide-activities-button
      gnomeExtensions.places-status-indicator
      gnomeExtensions.tweaks-in-system-menu
      gnomeExtensions.gtk4-desktop-icons-ng-ding
      nautilus-python
      nautilus-open-any-terminal
    ];
    #exclude some Gnome Packages
    environment.gnome.excludePackages = with pkgs;[
      geary # email
      epiphany # web browser
      yelp # help viewer
      gnome-maps
      gnome-weather
      gnome-tour
      gnome-contacts
    ];

    #fontDir.enable = true;
    fonts.packages = with pkgs; [
      corefonts
      dejavu_fonts
      freefont_ttf
      google-fonts
      inconsolata
      liberation_ttf
      ubuntu-classic
    ];
  };
}
