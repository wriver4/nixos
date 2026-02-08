{ config, pkgs, lib, ... }:

let
  # Build the MicroVM Dashboard from source
  microvm-dashboard = pkgs.buildNpmPackage rec {
    pname = "microvm-dashboard";
    version = "0.1.0";

    src = /home/mark/Projects/active/microvm-dashboard-project/code/MicroVM-Dashboard-Dev/backend;

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

    src = /home/mark/Projects/active/microvm-dashboard-project/code/MicroVM-Dashboard-Dev;

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

in
{
  config = {
    # System user for the dashboard service
    users.users.microvm-dashboard = {
      isSystemUser = true;
      group = "microvm-dashboard";
      home = "/var/lib/microvm-dashboard";
      createHome = true;
    };
    users.groups.microvm-dashboard = {};

    # Data directory
    systemd.tmpfiles.rules = [
      "d /var/lib/microvm-dashboard 0750 microvm-dashboard microvm-dashboard -"
    ];

    # Sudo rules: allow dashboard user to manage microvm@ units
    security.sudo.extraRules = [{
      users = [ "microvm-dashboard" ];
      commands = [
        { command = "/run/current-system/sw/bin/systemctl start microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl stop microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl restart microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl is-active microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl show microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl status microvm@*"; options = [ "NOPASSWD" ]; }
      ];
    }];

    # Systemd service
    systemd.services.microvm-dashboard = {
      description = "MicroVM Dashboard";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        NODE_ENV = "production";
        PORT = "3100";
        HOST = "0.0.0.0";
        LOG_LEVEL = "info";
        HOME = "/var/lib/microvm-dashboard";
        STATIC_DIR = "/var/www/microvm-dashboard";
      };

      serviceConfig = {
        Type = "simple";
        User = "microvm-dashboard";
        Group = "microvm-dashboard";
        ExecStart = "${pkgs.nodejs_24}/bin/node /var/lib/microvm-dashboard/backend/dist/index.js";
        Restart = "on-failure";
        RestartSec = "10s";
        WorkingDirectory = "/var/lib/microvm-dashboard";
      };
    };
  };
}
