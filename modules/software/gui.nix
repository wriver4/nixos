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
    kdePackages.ghostwriter


    #Browsers
    unstable.firefox
    vivaldi
    google-chrome
    brave
    # opera due to lack of support
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
    code-nautilus
    figma-linux
    filezilla
    libfilezilla
    #mailcatcher
    sqlitebrowser
    dbeaver-bin
    #pgadmin4
    #devbox
    httrack
    #flatpack-builder
    unstable.node-red
    unstable.bcompare
    unstable.emcee
    postman
    d2
    lunacy
    uv


    #irc like
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
    stacer
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
