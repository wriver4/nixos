{ config, pkgs, ... }:

{
  config = {
 
  
    environment.systemPackages = with pkgs; [
      git
      gitg
      gitui
      github-desktop
      gitlab
    ];

  };
}
