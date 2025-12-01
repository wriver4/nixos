{ config, pkgs, ... }:

{
  config = {
 
  
  environment.systemPackages = with pkgs; [
    git
    gitg
    gitui
    gitFull
    git-doc
    github-desktop 
  ];

  };
}
