{ config, pkgs, ... }:

{
  config = {

  # Good for SSD
  services.fstrim = {
    enable = true;
  };

  # nvidia
  hardware.nvidia= {
    powerManagement = {
      enable = true;
    };
  };
  
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
    packageOverrides = pkgs: {
      unstable = import <unstable> {
        config = config.nixpkgs.config;
      };
    };
  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "kvm-intel" ];
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };


  networking.hostName = "king"; 
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  #system.autoUpgrade.enable  = true;
  #system.autoUpgrade.allowReboot  = true;
  #system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.11";

  #nix.gc.automatic = true;
  #nix.gc.dates = "weekly";
  #nix.gc.options = "--delete-older-than 3d";

  #nix.settings.auto-optimise-store = true;

  
 
  environment.systemPackages = with pkgs; [
    #upower
    displaylink
    linuxKernel.packages.linux_6_6.nvidia_x11_legacy470
    nvtopPackages.nvidia
  ];

  };
}