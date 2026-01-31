{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      # AnyDesk remote desktop (package includes its own systemd service)
      anydesk
      # AnyDesk X11 mode desktop entry (for Wayland compatibility issues)
      (pkgs.makeDesktopItem {
        name = "anydesk-x11";
        desktopName = "AnyDesk (X11)";
        exec = "env GDK_BACKEND=x11 anydesk %u";
        icon = "anydesk";
        comment = "AnyDesk Remote Desktop (forced X11 mode)";
        categories = [ "Network" "RemoteAccess" ];
        mimeTypes = [ "x-scheme-handler/anydesk" ];
      })

      thunderbird
      unstable.nextcloud-talk-desktop
      #remote desktops
      remmina
      #viber
      #teamspeak3client

      # irc like
      telegram-desktop
      slack
      discord
      element-desktop
      zoom-us
      #xdg-desktop-portal
      #xdg-desktop-portal-gnome
      vesktop
      signal-desktop
      rocketchat-desktop
    ];
  };
}
