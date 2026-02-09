{ config, pkgs, lib, ... }:

let
  # Build the MicroVM Dashboard from source
  microvm-dashboard = pkgs.buildNpmPackage rec {
    pname = "microvm-dashboard";
    version = "0.1.0";

    src = /home/mark/Projects/active/microvm-dashboard-project/code/MicroVM-Dashboard-Dev-Premium/backend;

    npmDepsHash = lib.fakeHash;

    nodejs = pkgs.nodejs_24;

    buildPhase = ''
      npm run build
    '';

    installPhase = ''
      mkdir -p $out/lib/microvm-dashboard
      cp -r dist/* $out/lib/microvm-dashboard/
      cp package.json $out/lib/microvm-dashboard/
      cp -r node_modules $out/lib/microvm-dashboard/

      mkdir -p $out/bin
      cat > $out/bin/microvm-dashboard << EOF
      #!/usr/bin/env bash
      exec ${pkgs.nodejs_24}/bin/node $out/lib/microvm-dashboard/index.js
      EOF
      chmod +x $out/bin/microvm-dashboard
    '';

    meta = with lib; {
      description = "NixOS MicroVM Management Dashboard";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  # Build the frontend SPA
  microvm-dashboard-frontend = pkgs.buildNpmPackage rec {
    pname = "microvm-dashboard-frontend";
    version = "0.1.0";

    src = /home/mark/Projects/active/microvm-dashboard-project/code/MicroVM-Dashboard-Dev-Premium;

    npmDepsHash = lib.fakeHash;

    nodejs = pkgs.nodejs_24;

    buildPhase = ''
      npx quasar build
    '';

    installPhase = ''
      mkdir -p $out
      cp -r dist/spa/* $out/
    '';
  };

  premiumBackendDir = "/home/mark/Projects/active/microvm-dashboard-project/code/MicroVM-Dashboard-Dev-Premium/backend";

in
{
  config = {
    # System user for the dashboard service
    users.users.microvm-dashboard = {
      isSystemUser = true;
      group = "microvm-dashboard";
      home = "/var/lib/microvm-dashboard";
      createHome = true;
      extraGroups = [ "kvm" ];
    };
    users.groups.microvm-dashboard = {};

    # Data + microvms directories
    # Owned by mark:users to match serviceConfig.User (dev mode runs from source)
    systemd.tmpfiles.rules = [
      "d /var/lib/microvm-dashboard 0750 mark users -"
      "d /var/lib/microvms 0755 mark users -"
    ];

    # Sudo rules: allow dashboard user to manage microvm@ units + provisioning
    security.sudo.extraRules = [{
      users = [ "microvm-dashboard" "mark" ];
      commands = [
        # Existing: manage microvm@ systemd units
        { command = "/run/current-system/sw/bin/systemctl start microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl stop microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl restart microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl is-active microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl show microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl status microvm@*"; options = [ "NOPASSWD" ]; }

        # Provisioning: microvm CLI for NixOS guests
        { command = "/run/current-system/sw/bin/microvm *"; options = [ "NOPASSWD" ]; }

        # Provisioning: install cloud VM systemd units + reload
        { command = "/run/current-system/sw/bin/systemctl daemon-reload"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/cp * /etc/systemd/system/microvm@*.service"; options = [ "NOPASSWD" ]; }
      ];
    }];

    # Systemd service
    systemd.services.microvm-dashboard = {
      description = "MicroVM Dashboard (Premium)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.cdrkit pkgs.qemu ];

      environment = {
        NODE_ENV = "production";
        PORT = "3100";
        HOST = "0.0.0.0";
        LOG_LEVEL = "info";
        HOME = "/var/lib/microvm-dashboard";
        STATIC_DIR = "/var/www/microvm-dashboard";

        # Premium features
        PREMIUM_ENABLED = "true";
        VM_STORAGE_BACKEND = "json";
        VM_DATA_DIR = "/var/lib/microvm-dashboard";

        # Provisioning
        PROVISIONING_ENABLED = "true";
        MICROVMS_DIR = "/var/lib/microvms";
        BRIDGE_GATEWAY = "10.10.0.1";
        BRIDGE_INTERFACE = "br-microvm";
        MICROVM_BIN = "/run/current-system/sw/bin/microvm";
        QEMU_BIN = "${pkgs.qemu}/bin/qemu-system-x86_64";
        QEMU_IMG_BIN = "${pkgs.qemu}/bin/qemu-img";
      };

      serviceConfig = {
        Type = "simple";
        User = "mark";
        Group = "users";
        ExecStart = "${pkgs.nodejs_24}/bin/node ${premiumBackendDir}/dist/index.js";
        Restart = "on-failure";
        RestartSec = "10s";
        WorkingDirectory = premiumBackendDir;
      };
    };
  };
}
