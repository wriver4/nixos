{ config, pkgs, lib, ... }:

let
  devBackendDir = "/home/mark/Projects/active/microvm-dashboard-project/code/MicroVM-Dashboard-Dev/backend";
in
{
  config = {
    # System user for the dashboard service (exists for sudo rules;
    # the service itself runs as mark in dev mode)
    users.users.microvm-dashboard = {
      isSystemUser = true;
      group = "microvm-dashboard";
      home = "/var/lib/microvm-dashboard";
      # createHome intentionally omitted — tmpfiles rule below handles
      # directory creation with mark:users ownership (dev mode).
      # createHome would set microvm-dashboard:microvm-dashboard 0700,
      # conflicting with the service running as mark.
      extraGroups = [ "kvm" ];
    };
    users.groups.microvm-dashboard = {};

    # Data + microvms directories
    # Owned by mark:users to match serviceConfig.User (dev mode runs from source)
    systemd.tmpfiles.rules = [
      "d /var/lib/microvm-dashboard 0750 mark users -"
      "d /var/lib/microvms 0755 mark users -"
    ];

    # Sudo rules: allow dashboard user + mark to manage microvm@ units + provisioning
    security.sudo.extraRules = [{
      users = [ "microvm-dashboard" "mark" ];
      commands = [
        # Manage microvm@ systemd units
        { command = "/run/current-system/sw/bin/systemctl start microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl stop microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl restart microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl is-active microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl show microvm@*"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl status microvm@*"; options = [ "NOPASSWD" ]; }

        # Provisioning: microvm CLI for NixOS guests
        { command = "/run/current-system/sw/bin/microvm *"; options = [ "NOPASSWD" ]; }

        # Provisioning: TAP interface management for cloud VMs
        { command = "/run/current-system/sw/bin/ip tuntap add * mode tap user *"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/ip tuntap del * mode tap"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/ip link set * master br-microvm"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/ip link set * up"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/ip link set * down"; options = [ "NOPASSWD" ]; }

        # Provisioning: install cloud VM systemd units + reload
        { command = "/run/current-system/sw/bin/systemctl daemon-reload"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/cp * /etc/systemd/system/microvm@*.service"; options = [ "NOPASSWD" ]; }
      ];
    }];

    # Systemd service — runs from dev source tree as mark
    systemd.services.microvm-dashboard = {
      description = "MicroVM Dashboard";
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

        # System paths (NixOS uses non-standard locations)
        SUDO_PATH = "/run/wrappers/bin/sudo";
        SYSTEMCTL_PATH = "/run/current-system/sw/bin/systemctl";
        IPTABLES_PATH = "/run/current-system/sw/bin/iptables";
        IP_BIN = "/run/current-system/sw/bin/ip";

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
        ExecStart = "${pkgs.nodejs_24}/bin/node ${devBackendDir}/dist/index.js";
        Restart = "on-failure";
        RestartSec = "10s";
        WorkingDirectory = devBackendDir;
      };
    };
  };
}
