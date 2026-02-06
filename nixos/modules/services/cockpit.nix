{ config, pkgs, ... }:

{
  # Cockpit — web-based system & container management
  # Web console: http://localhost:9090
  services.cockpit = {
    enable = true;
    port = 9090;
  };
}
