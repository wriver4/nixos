{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      angryipscanner
      #zmap
      #netscanner
      #iperf3d
      #netbird-ui
      wireshark
      localsend
    ];
  };
}
