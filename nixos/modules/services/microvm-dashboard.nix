{ config, pkgs, lib, ... }:

{
  imports = [
    /home/mark/Projects/active/microvm-dashboard-project/code/MicroVM-Dashboard-Dev/nixos/default.nix
  ];

  config = {
    services.microvm-dashboard = {
      enable = true;
      port = 3100;
      host = "0.0.0.0";
      openFirewall = true;

      # Premium + provisioning
      premiumEnabled = true;
      provisioningEnabled = true;
      bridgeInterface = "br-microvm";
      bridgeGateway = "10.10.0.1";
      microvmsDir = "/var/lib/microvms";

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
