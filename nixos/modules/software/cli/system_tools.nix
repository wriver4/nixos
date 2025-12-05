{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      pciutils # lspci
      usbutils # lsusb
      inetutils # ping, telnet, ftp, rcp, rlogin, rsh, rwho, tftp, rcp
      smartmontools # for `smartctl` command

      # provisioning
      disko # Declarative disk partitioning and formatting using nix

      # low level tools
      binutils # A collection of binary tools
      testdisk # Data recovery software
    ];
  };
}
