{ config, pkgs, lib, ... }:

{
  config = {

    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # GNOME Remote Desktop (RDP via PipeWire — works natively on Wayland)
    services.gnome.gnome-remote-desktop.enable = true;
    systemd.services.gnome-remote-desktop = {
      wantedBy = [ "graphical.target" ];
    };

    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;

    programs.dconf.profiles.user.databases = [{
      settings = with lib.gvariant; {
        "org/gnome/shell" = {
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "dash-to-dock@micxgx.gmail.com"
            "ding@rastersoft.com"
            "fq@megh"
            "Hide_Activities@shay.shayel.org"
            "monitor@astraext.github.io"
            "places-menu@gnome-shell-extensions.gcampax.github.com"
            "systemd-manager@hardpixel.eu"
            "tweaks-system-menu@extensions.gnome-shell.fifi.org"
          ];
        };
        "org/gnome/desktop/input-sources" = {
          # XKB-only — prevents GNOME from starting IBus (EN_US, no input methods needed)
          sources = mkArray [ (mkTuple [ "xkb" "us" ]) ];
        };
        "org/gnome/shell/extensions/ding" = {
          show-home = true;       # or true, your call
          show-trash = true;
          show-volumes = true;
          icon-size = "standard";     # 'small' | 'standard' | 'large'
        };
      };
    }];

    programs.seahorse.enable = true;
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "terminator";
    };

    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
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
      gnome-remote-desktop
      #extensions
      gnomeExtensions.astra-monitor
      libgtop
      gnomeExtensions.force-quit
      gnomeExtensions.dash-to-dock
      gnomeExtensions.hide-activities-button
      gnomeExtensions.places-status-indicator
      gnomeExtensions.appindicator
      gnomeExtensions.desktop-icons-ng-ding
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
