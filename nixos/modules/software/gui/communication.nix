{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      thunderbird
      unstable.nextcloud-talk-desktop
      #remote desktops
      unstable.anydesk
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
