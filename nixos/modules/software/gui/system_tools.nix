{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
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
  };
}
