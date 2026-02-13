{ config, pkgs, lib, ... }:

{
  config = {
    # Bridge networking for MicroVM connectivity
    networking.bridges.br-microvm.interfaces = [];
    networking.interfaces.br-microvm.ipv4.addresses = [{
      address = "10.10.0.1";
      prefixLength = 24;
    }];

    # NAT for VM internet access
    networking.nat = {
      enable = true;
      internalInterfaces = [ "br-microvm" ];
    };

    # Trust bridge traffic (no firewall filtering between host and VMs)
    networking.firewall.trustedInterfaces = [ "br-microvm" ];

    # IP forwarding
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  };
}
