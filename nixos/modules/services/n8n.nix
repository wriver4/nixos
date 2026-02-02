{ config, pkgs, lib, ... }:

let
  # n8n icon
  n8nIcon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/n8n-io/n8n/master/assets/n8n-logo.png";
    sha256 = "sha256-X9QfKy4AJrsg6CMlnmq0HuVmsa9She1B1LKoL9rDNBo=";
  };

  # Desktop item to start n8n service
  n8nStart = pkgs.makeDesktopItem {
    name = "n8n-start";
    desktopName = "Start n8n";
    exec = "/run/wrappers/bin/pkexec ${pkgs.systemd}/bin/systemctl start n8n";
    icon = "media-playback-start";
    type = "Application";
    categories = [ "Development" "Utility" "Network" ];
    comment = "Start n8n workflow automation service";
  };

  # Desktop item to stop n8n service
  n8nStop = pkgs.makeDesktopItem {
    name = "n8n-stop";
    desktopName = "Stop n8n";
    exec = "/run/wrappers/bin/pkexec ${pkgs.systemd}/bin/systemctl stop n8n";
    icon = "media-playback-stop";
    type = "Application";
    categories = [ "Development" "Utility" "Network" ];
    comment = "Stop n8n workflow automation service";
  };
in
{
  config = {
    # System user for n8n
    users.users.n8n = {
      isSystemUser = true;
      group = "n8n";
      home = "/var/lib/n8n";
      createHome = true;
    };
    users.groups.n8n = {};

    # Data directory
    systemd.tmpfiles.rules = [
      "d /var/lib/n8n 0750 n8n n8n -"
    ];

    # n8n systemd service
    systemd.services.n8n = {
      description = "n8n Workflow Automation";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        N8N_USER_FOLDER = "/var/lib/n8n";
        N8N_PORT = "5678";
        HOME = "/var/lib/n8n";
        # Uncomment to enable basic auth:
        # N8N_BASIC_AUTH_ACTIVE = "true";
        # N8N_BASIC_AUTH_USER = "admin";
        # N8N_BASIC_AUTH_PASSWORD = "changeme";
      };

      serviceConfig = {
        Type = "simple";
        User = "n8n";
        Group = "n8n";
        ExecStart = "${pkgs.unstable.n8n}/bin/n8n start";
        Restart = "on-failure";
        RestartSec = "10s";
        WorkingDirectory = "/var/lib/n8n";
      };
    };

    # Desktop launchers
    environment.systemPackages = [ n8nStart n8nStop ];

    # Uncomment to allow access from other machines:
    # networking.firewall.allowedTCPPorts = [ 5678 ];
  };
}
