{ config, pkgs, ... }:

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
    # drawing
    drawio

    #Communication
    unstable.thunderbird-latest-unwrapped
    unstable.nextcloud-talk-desktop
    unstable.anydesk
    #discord
    #zoom-client
    #slack-desktop
    #signal-desktop
    #telegram-desktop
    #whatsapp-for-linux
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
    # unstable.bcompare
    # unstable.emcee
    postman
    # d2
    # lunacy
    uv
    unstable.n8n
    unstable.playwright-test
    kdePackages.ghostwriter # markdown editor
    jetbrains.pycharm-community
    jetbrains-toolbox
    android-studio
    eclipses.eclipse-jee
    # zulu24
    # unstable.ida-free was in a hurry
    #Please go to https://my.hex-rays.com/dashboard/download-center/9.1/ida-free to download it yourself, and add it to the Nix store
    #   > using either
    #   >   nix-store --add-fixed sha256 ida-free-pc_91_x64linux.run
    #   > or
    #   >   nix-prefetch-url --type sha256 file:///path/to/ida-free-pc_91_x64linux.run
    #   >
    #   > ***
    
  


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
