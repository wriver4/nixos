{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.microvm-dashboard.nixosModules.default
  ];

  config = {
    services.microvm-dashboard = {
      enable = true;
      port = 3100;
      host = "0.0.0.0";
      openFirewall = true;

      # Premium
      premiumEnabled = true;

      # Storage
      storageBackend = "json";
      dataDir = "/var/lib/microvm-dashboard";

      # Auth (create these files before first nixos-rebuild, see deployment steps)
      jwtSecretFile = "/var/lib/microvm-dashboard/.jwt-secret";
      initialAdminPasswordFile = "/var/lib/microvm-dashboard/.admin-password";
    };

    # Trust bridge traffic (host <-> VM, not in the module)
    networking.firewall.trustedInterfaces = [ "br-microvm" ];
  };
}
