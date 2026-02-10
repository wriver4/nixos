{ config, pkgs, lib, ... }:

{
  config = {

    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

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
      #extensions
      # gnomeExtensions.tophat
      gnomeExtensions.astra-monitor
      libgtop
      gnomeExtensions.force-quit
      gnomeExtensions.dash-to-dock
      gnomeExtensions.hide-activities-button
      gnomeExtensions.places-status-indicator
      gnomeExtensions.tweaks-in-system-menu
      nautilus-python
      nautilus-open-any-terminal
    ];
    # Needed for astra-monitor (libgtop GObject introspection)
    environment.variables.GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";

    #exclude some Gnome Packages
    environment.gnome.excludePackages = with pkgs;[
      geary # email
      yelp # help viewer
      gnome-maps
      gnome-weather
      gnome-tour
      gnome-contacts
      epiphany # web browser
    ];

    # Hide desktop icons for CLI-only tools
    environment.etc."xdg/applications/nvtop.desktop".text = ''
      [Desktop Entry]
      NoDisplay=true
    '';

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
