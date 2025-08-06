{ config, pkgs, lib, inputs, ... }:

with lib;

{
  options.services.claude-desktop = {
    enable = mkEnableOption "Claude Desktop application";
    
    package = mkOption {
      type = types.package;
      default = inputs.claude-desktop.packages.${pkgs.system}.claude-desktop;
      description = "The Claude Desktop package to use";
    };
    
    withMcpSupport = mkOption {
      type = types.bool;
      default = false;
      description = "Enable MCP (Model Context Protocol) server support with FHS environment";
    };
  };

  config = mkIf config.services.claude-desktop.enable {
    # Add Claude Desktop to system packages
    environment.systemPackages = [
      config.services.claude-desktop.package
      
      # Required system dependencies
      pkgs.libnotify   # For notifications
      pkgs.xdg-utils   # For opening URLs and file associations
    ];

    # GNOME/Desktop Environment Integration
    services.xserver = mkIf (config.services.xserver.enable) {
      # Ensure desktop session support
      desktopManager.session = [{
        name = "claude-desktop";
        start = "";
      }];
    };

    # Enable XDG desktop portal for better desktop integration
    xdg.portal = {
      enable = mkDefault true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk  # For file dialogs and desktop integration
      ];
    };

    # Ensure proper font rendering for Electron apps
    fonts.packages = with pkgs; [
      liberation_ttf
      dejavu_fonts
      ubuntu_font_family
    ];

    # Optional: Create a systemd user service for Claude Desktop
    # This allows it to start automatically with the user session
    systemd.user.services.claude-desktop = {
      description = "Claude Desktop Application";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${config.services.claude-desktop.package}/bin/claude-desktop";
        Restart = "on-failure";
        RestartSec = 5;
        # Ensure proper environment for desktop apps
        Environment = [
          "XDG_SESSION_TYPE=x11"  # or wayland, depending on your setup
          "QT_QPA_PLATFORM=xcb"   # For Qt applications
        ];
      };
      
      # Only enable if explicitly requested
      enable = false;  # Set to true if you want auto-start
    };

    # Environment variables for Electron apps
    environment.sessionVariables = {
      # Fix for Electron apps in Wayland
      #NIXOS_OZONE_WL = mkIf config.programs.wayland.enable "1";
    };
  };
}