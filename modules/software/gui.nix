{ config, pkgs, ... }:

{
  config = {
  #services.stirling-pdf.enable=true;
    
  environment.systemPackages = with pkgs; [
    # text editors
    libreoffice-fresh
    geany
    marktext
    #stirling-pdf


    #Browsers
    unstable.firefox
    vivaldi
    google-chrome
    brave
    opera
    element-web
    vdhcoapp

    #Media
    vlc
    spotify
    shotcut
    simplescreenrecorder
    krita
    gimp
    obs-studio
    imagemagick # image manipulation
    #drawing
    drawio

    #Communication
    thunderbird
    unstable.nextcloud-talk-desktop

    # Security
     fwbuilder
     clamtk
     _1password-gui

    # support
    # rustdesk
    
    # Dev Tools
    terminator
    kdiff3
    vscode
    figma-linux
    filezilla
    libfilezilla
    #mailcatcher
    sqlitebrowser
    mysql-workbench
    #pgadmin4
    #devbox
    httrack
    #flatpack-builder
    unstable.node-red
    unstable.bcompare 


    #irc like
    telegram-desktop
    slack
    discord
    element-desktop
    zoom-us
    xdg-desktop-portal
    xdg-desktop-portal-gnome
    vesktop
    signal-desktop
    rocketchat-desktop

    # networking
    angryipscanner
    #zmap
    #netscanner
    #iperf3d
    #netbird-ui
    wireshark
    localsend
  
    # disk tools
    gparted
    gsmartcontrol
    usbimager

    # system tools
    #nagios # network monitoring key CSP50

    # repair tools and utilities
    wxhexeditor
    phoronix-test-suite
    #testdisk-qt
  ];
  # unstable
    # nextcloud-talk-desktop
    # firefox

  # flatpacks
    # AnyDesk
    # Gaphor
    # Github Desktop
    # masterpdfeditor
    # Podman Desktop
    # boxy-svg
    # image optimizer
    # dropbox
    # lightworks
  
  # appimages
    # Lepton

  # vm's
    # beyondcompare
    # cockpit
  };
}
