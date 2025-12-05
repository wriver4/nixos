{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      mtr # A network diagnostic tool
      iperf3  # A tool to measure network performance
      dnsutils  # `dig` + `nslookup`
      aria2 # A lightweight multi-protocol & multi-source command-line download utility
      socat # replacement of openbsd-netcat
    ];
  };
}
