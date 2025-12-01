{ config, pkgs, lib, ... }:
let
  n8nDesktopItem = pkgs.makeDesktopItem {
    name = "n8n-launcher";
    desktopName = "n8n Workflow Automation";
    exec = "${pkgs.n8n}/bin/n8n"; # Ensure n8n is available in pkgs
    icon = "n8n";
    type = "Application";
    categories = [ "Development" "Utility" ];
  };
in
{
  config = {
  #services.stirling-pdf.enable=true;
    
  environment.systemPackages = with pkgs; [
    # text editors
    libreoffice-fresh 
    hunspell # spell checker for libreoffice
    geany
    marktext
    #stirling-pdf

    
    # AI
    # lmstudio
    # vllm
    # llama-cpp
    # openai-whisper
    # whisperx
    # stable-diffusion-webui
    # ollama
    # ollama-cuda
    # gollama


    #Browsers
    unstable.firefox
    vivaldi
    google-chrome
    brave
    chromium
    # browsers # I am not ready yet
    # opera due to lack of support
    element-web
    # vdhcoapp

    #Media
    vlc
    spotify
    shotcut
    simplescreenrecorder
    krita
    gimp
    obs-studio
    imagemagick # image manipulation
    cobang  # qrcode scanner

    # drawing
    drawio

    #Communication
    thunderbird
    unstable.nextcloud-talk-desktop
    unstable.anydesk
    #viber
    #teamspeak3client

    # Security
     fwbuilder
     clamtk
     _1password-gui

    # support
    # rustdesk
    
    # Dev Tools
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
    #pgadmin4
    #devbox
    httrack
    # flatpack-builder
    # unstable.node-red
    unstable.bcompare
    unstable.emcee
    postman
    # d2
    # lunacy
    uv
    unstable.n8n
    n8nDesktopItem
    playwright-test
    kdePackages.ghostwriter # markdown editor
    jetbrains.pycharm-community
    jetbrains-toolbox
    android-studio
    eclipses.eclipse-jee
    docker-compose
    
  


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


  # flatpacks list
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
