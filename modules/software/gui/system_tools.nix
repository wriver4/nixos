{ config, pkgs, ... }:

{
  config = {
    hardware.logitech.wireless.enable = true;
    hardware.logitech.wireless.enableGraphical = true;

    environment.systemPackages = with pkgs; [
      # disk tools
      gparted
      gsmartcontrol
      usbimager

      # system tools
      solaar
      #nagios # network monitoring key CSP50

      # repair tools and utilities
      wxhexeditor
      phoronix-test-suite
      #testdisk-qt
    ];
  };
}
