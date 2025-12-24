{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      #angryipscanner
      watchyourlan
      zenmap
      #netscanner
      #iperf3d
      #netbird-ui
      wireshark
      localsend
    ];
  };
}
