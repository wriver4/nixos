{ config, pkgs, ... }:

let
  cockpit-navigator = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "cockpit-navigator";
    version = "0.5.12";
    src = pkgs.fetchFromGitHub {
      owner = "45Drives";
      repo = "cockpit-navigator";
      rev = "v${version}";
      hash = "sha256-1CRTTMyKdRQGwIdEVCwDH4nS4t6YzebNEUYRogWwpTc=";
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/cockpit
      cp -r navigator $out/share/cockpit/navigator
    '';
  };
in
{
  # Cockpit — web-based system & container management
  # Web console: http://localhost:9090
  services.cockpit = {
    enable = true;
    port = 9090;
  };

  # Cockpit Navigator — file browser plugin (45Drives Houston)
  environment.systemPackages = [ cockpit-navigator ];
}
