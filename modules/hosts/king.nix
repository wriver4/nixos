{ pkgs, ... }:

{
  config = {

    # Good for SSD
    services.fstrim = {
      enable = true;
    };

    services.fwupd.enable = true;

    # nvidia
    #hardware.nvidia = {
    #  powerManagement = {
     #   enable = true;
    #  };
   # };

    swapDevices = [ ];
    zramSwap.enable = true;

    services.avahi.nssmdns4 = true;

    services.usbguard = {
      enable = true;
      # Allow-all initial policy — tighten with `sudo usbguard generate-policy` after verifying devices
      rules = ''
        allow id *:*
      '';
    };

    # Uncomment to explicitly exclude zfs if a channel update re-introduces it
    # boot.supportedFilesystems = lib.mkForce [ "ext4" "vfat" ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 3;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = [ "intel_iommu=on" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModprobeConfig = "options kvm_intel nested=1";
    hardware.cpu.intel.updateMicrocode = true;
    boot.binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

    networking.hostName = "<your-hostname>";
    networking.search = [ "<your-domain>" "local" ];

    # Enable networking
    networking.networkmanager.enable = true;

    # Phase 9 networking: two-NIC layout.
    #
    #   enp0s25  1G   Intel I217-LM  — Trust (<your-trust-ip>/24), default route, internet
    #   enp11s0  2.5G Intel I226-V   — Dev   (<your-dev-ip>/24),  no default route
    #
    # Cable positions:
    #   enp0s25 → dumb 8-port switch → ER707 Trust port (Port 4)
    #   enp11s0 → TL-SG105S-M2 Dev switch (Port 2) → ER707 Dev port (Port 2)
    #
    # After nixos-rebuild switch, move both cables before reconnecting to the network.
    # Order: enp0s25 to Trust first (restores internet), then enp11s0 to Dev.
    networking.networkmanager.ensureProfiles.profiles = {

      # 1G NIC — Trust interface, carries default route and internet access.
      # DNS points at the Blocky microvm (<your-dns-ip>) reachable via the
      # ER707 Trust→DMZ cross-VLAN route defined in route1 below.
      trust-enp0s25 = {
        connection = {
          id = "trust-enp0s25";
          type = "ethernet";
          interface-name = "enp0s25";
          autoconnect = true;
        };
        ipv4 = {
          method = "manual";
          address1 = "<your-trust-ip>/24,<your-gateway>";
          dns = "<your-dns-ip>;1.1.1.1;";
          route1 = "<your-dmz-subnet>,<your-gateway>,100";
        };
        ipv6 = {
          method = "link-local";
        };
      };

      # 2.5G NIC — Dev interface, high-bandwidth path to foundry/weaver and NAS.
      # never-default keeps the internet default route on enp0s25.
      # No DNS entry: DNS traffic takes the Trust NIC path automatically.
      dev-enp11s0 = {
        connection = {
          id = "dev-enp11s0";
          type = "ethernet";
          interface-name = "enp11s0";
          autoconnect = true;
        };
        ethernet = {
          mac-address = "<your-mac-address>";
        };
        ipv4 = {
          method = "manual";
          address1 = "<your-dev-ip>/24";
          never-default = true;
          route-metric = 300;
        };
        ipv6 = {
          method = "link-local";
        };
      };

    };

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


    environment.systemPackages = with pkgs; [
      wsdd
    ];

  };
}
