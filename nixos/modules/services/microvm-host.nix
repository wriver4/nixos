{ config, pkgs, lib, inputs, ... }:

{
  config = {
    # ── Bridge Network ──────────────────────────────────────────────
    systemd.network = {
      enable = true;
      netdevs."10-br-microvm" = {
        netdevConfig = {
          Name = "br-microvm";
          Kind = "bridge";
        };
      };
      networks."10-br-microvm" = {
        matchConfig.Name = "br-microvm";
        networkConfig = {
          Address = "10.10.0.1/24";
          DHCPServer = false;
        };
      };
    };

    # NAT masquerade for MicroVM internet access
    networking.nat = {
      enable = true;
      internalInterfaces = [ "br-microvm" ];
      externalInterface = "enp0s25";
    };

    # IP forwarding
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    # Allow traffic on bridge
    networking.firewall.trustedInterfaces = [ "br-microvm" ];

    # ── MicroVM Definitions ─────────────────────────────────────────

    microvm.vms = {
      # Web stack: nginx reverse proxy
      web-nginx = {
        autostart = false;
        flake = inputs.microvm;
        updateFlake = "microvm";
        config = { config, pkgs, ... }: {
          microvm = {
            hypervisor = "qemu";
            mem = 256;
            vcpu = 1;
            shares = [{
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              proto = "virtiofs";
            }];
            interfaces = [{
              type = "tap";
              id = "vm-web-nginx";
              mac = "02:00:00:00:01:01";
            }];
          };
          systemd.network = {
            enable = true;
            networks."20-eth0" = {
              matchConfig.Type = "ether";
              networkConfig = {
                Address = "10.10.0.10/24";
                Gateway = "10.10.0.1";
                DNS = [ "10.10.0.1" "1.1.1.1" ];
              };
            };
          };
          networking.hostName = "web-nginx";
          services.nginx = {
            enable = true;
            virtualHosts."default" = {
              default = true;
              locations."/" = {
                proxyPass = "http://10.10.0.11:3000";
              };
            };
          };
          networking.firewall.allowedTCPPorts = [ 80 443 ];
          users.users.root.password = "";
          system.stateVersion = "25.05";
        };
      };

      # Web stack: Node.js application server
      web-app = {
        autostart = false;
        flake = inputs.microvm;
        updateFlake = "microvm";
        config = { config, pkgs, ... }: {
          microvm = {
            hypervisor = "qemu";
            mem = 512;
            vcpu = 1;
            shares = [{
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              proto = "virtiofs";
            }];
            interfaces = [{
              type = "tap";
              id = "vm-web-app";
              mac = "02:00:00:00:01:02";
            }];
          };
          systemd.network = {
            enable = true;
            networks."20-eth0" = {
              matchConfig.Type = "ether";
              networkConfig = {
                Address = "10.10.0.11/24";
                Gateway = "10.10.0.1";
                DNS = [ "10.10.0.1" "1.1.1.1" ];
              };
            };
          };
          networking.hostName = "web-app";
          environment.systemPackages = with pkgs; [ nodejs_24 ];
          networking.firewall.allowedTCPPorts = [ 3000 ];
          users.users.root.password = "";
          system.stateVersion = "25.05";
        };
      };

      # Dev environment: Node.js
      dev-node = {
        autostart = false;
        flake = inputs.microvm;
        updateFlake = "microvm";
        config = { config, pkgs, ... }: {
          microvm = {
            hypervisor = "qemu";
            mem = 512;
            vcpu = 1;
            shares = [{
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              proto = "virtiofs";
            }];
            interfaces = [{
              type = "tap";
              id = "vm-dev-node";
              mac = "02:00:00:00:02:01";
            }];
          };
          systemd.network = {
            enable = true;
            networks."20-eth0" = {
              matchConfig.Type = "ether";
              networkConfig = {
                Address = "10.10.0.20/24";
                Gateway = "10.10.0.1";
                DNS = [ "10.10.0.1" "1.1.1.1" ];
              };
            };
          };
          networking.hostName = "dev-node";
          environment.systemPackages = with pkgs; [ nodejs_24 git vim ];
          users.users.root.password = "";
          system.stateVersion = "25.05";
        };
      };

      # Dev environment: Python
      dev-python = {
        autostart = false;
        flake = inputs.microvm;
        updateFlake = "microvm";
        config = { config, pkgs, ... }: {
          microvm = {
            hypervisor = "qemu";
            mem = 512;
            vcpu = 1;
            shares = [{
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              proto = "virtiofs";
            }];
            interfaces = [{
              type = "tap";
              id = "vm-dev-python";
              mac = "02:00:00:00:02:02";
            }];
          };
          systemd.network = {
            enable = true;
            networks."20-eth0" = {
              matchConfig.Type = "ether";
              networkConfig = {
                Address = "10.10.0.21/24";
                Gateway = "10.10.0.1";
                DNS = [ "10.10.0.1" "1.1.1.1" ];
              };
            };
          };
          networking.hostName = "dev-python";
          environment.systemPackages = with pkgs; [
            (python3.withPackages (ps: with ps; [ pip virtualenv ]))
            git vim
          ];
          users.users.root.password = "";
          system.stateVersion = "25.05";
        };
      };

      # Service isolation: PostgreSQL
      svc-postgres = {
        autostart = false;
        flake = inputs.microvm;
        updateFlake = "microvm";
        config = { config, pkgs, ... }: {
          microvm = {
            hypervisor = "qemu";
            mem = 512;
            vcpu = 1;
            shares = [{
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              proto = "virtiofs";
            }];
            interfaces = [{
              type = "tap";
              id = "vm-svc-pg";
              mac = "02:00:00:00:03:01";
            }];
          };
          systemd.network = {
            enable = true;
            networks."20-eth0" = {
              matchConfig.Type = "ether";
              networkConfig = {
                Address = "10.10.0.30/24";
                Gateway = "10.10.0.1";
                DNS = [ "10.10.0.1" "1.1.1.1" ];
              };
            };
          };
          networking.hostName = "svc-postgres";
          services.postgresql = {
            enable = true;
            package = pkgs.postgresql_16;
            enableTCPIP = true;
            authentication = lib.mkForce ''
              # TYPE  DATABASE  USER  ADDRESS       METHOD
              local   all       all                 peer
              host    all       all   10.10.0.0/24  md5
              host    all       all   127.0.0.1/32  md5
            '';
          };
          networking.firewall.allowedTCPPorts = [ 5432 ];
          users.users.root.password = "";
          system.stateVersion = "25.05";
        };
      };
    };
  };
}
