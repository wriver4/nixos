{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      fwbuilder
      clamtk
      _1password-gui
    ];
  };
}
