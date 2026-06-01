{ config, pkgs, ... }:

{
  config = {
    # Pull in the anydesk package's systemd service file
    systemd.packages = [ pkgs.anydesk ];

    # Protect AnyDesk daemon from being OOM killed (overlays on the package service)
    systemd.services.anydesk = {
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ iproute2 util-linux nettools glibc.bin ];
      serviceConfig = {
        OOMScoreAdjust = -500;
        MemoryHigh = "infinity";
      };
    };

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
      # Zoom with GPU acceleration disabled — prevents nouveau CTXSW_TIMEOUT
      # crash under video load (GK107/NVS 510 incompatibility with nouveau).
      (pkgs.makeDesktopItem {
        name = "zoom-us";
        desktopName = "Zoom";
        exec = "env LIBGL_ALWAYS_SOFTWARE=1 ${pkgs.zoom-us}/bin/zoom %U";
        icon = "Zoom";
        comment = "Zoom Video Conferencing (software rendering)";
        categories = [ "Network" "InstantMessaging" ];
        mimeTypes = [ "x-scheme-handler/zoom" "x-scheme-handler/zoommtg" "x-scheme-handler/zoomus" ];
        startupWMClass = "zoom";
      })
      #xdg-desktop-portal
      #xdg-desktop-portal-gnome
      vesktop
      signal-desktop
      rocketchat-desktop
    ];
  };
}
