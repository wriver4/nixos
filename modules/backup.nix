{ config, pkgs, ... }:

{
  config = {
  # borgmatic
  #services.borgmatic.enable = true;
  environment.systemPackages = with pkgs;[
    #borgbackup
    #vorta
    #borgmatic
  ];
  };
}