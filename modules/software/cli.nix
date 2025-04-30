{ config, pkgs, inputs, ... }:

{
  config = {
  environment.systemPackages = with pkgs; [
    # archive utilities
    zip
    xz
    unzip
    p7zip
    gzip
    gzrt
    bzip2

    # find utils
    ripgrep
    fzf

    # cli tools
    tmux
    neofetch
    eza
    tree
    bat

    # networking tools
    mtr # A network diagnostic tool
    iperf3  # A tool to measure network performance
    dnsutils  # `dig` + `nslookup`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat

    # productivity
    glow # markdown previewer in terminal
    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat # sar, iostat, mpstat, pidstat, sadf
    lm_sensors # for `sensors` command
    ethtool # for `ethtool` command
    pciutils # lspci
    usbutils # lsusb
    inetutils # ping, telnet, ftp, rcp, rlogin, rsh, rwho, tftp, rcp
    smartmontools # for `smartctl` command
    
    # provisioning
    disko # Declarative disk partitioning and formatting using nix

    # low level tools
    binutils # A collection of binary tools
    testdisk # Data recovery software
    
    #misc
    ffmpeg_7-full # A complete, cross-platform solution to record, convert and stream audio and video
    clamav # Antivirus engine for detecting trojans, viruses, malware & other malicious threats
    clamsmtp # A lightweight SMTP filter for ClamAV

    # programming languages
    python3 # A high-level programming language
    gcc-unwrapped # The GNU Compiler Collection - C and C++ frontends
    gnumake # GNU version of 'make' utility

    #formatters
    nixpkgs-fmt # current official style use nixpkgs-fmt --check file.nix
    nixfmt-rfc-style # new official style use nixfmt --check file.nix
    #nit needed if using vscode use vscode plugin nix-ide
    #nixd # nix language server
  ];
  # required by nixd
  #nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; 
  };
}