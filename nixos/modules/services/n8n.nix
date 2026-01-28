{ config, pkgs, lib, ... }:

let
  # Desktop item to open n8n in Epiphany as a web app
  n8nWebApp = pkgs.makeDesktopItem {
    name = "n8n";
    desktopName = "n8n Workflow Automation";
    exec = "${pkgs.epiphany}/bin/epiphany --new-window --application-mode http://localhost:5678";
    icon = "n8n";
    type = "Application";
    categories = [ "Development" "Utility" "Network" ];
    comment = "n8n workflow automation (web app)";
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

    # Desktop launcher (opens in Epiphany app mode)
    environment.systemPackages = [ n8nWebApp ];

    # Uncomment to allow access from other machines:
    # networking.firewall.allowedTCPPorts = [ 5678 ];
  };
}
