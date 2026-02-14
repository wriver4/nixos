{ config, pkgs, lib, ... }:

{
  # Bridge networking and NAT are now managed by the microvm-dashboard module
  # when provisioningEnabled = true. See microvm-dashboard.nix.
  #
  # Previously this file configured:
  #   - networking.bridges.br-microvm
  #   - networking.nat (internalInterfaces)
  #   - boot.kernel.sysctl ip_forward
  #
  # The module in nixos/default.nix handles all of this when
  # services.microvm-dashboard.provisioningEnabled = true.
}
