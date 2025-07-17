{ config, pkgs, ... }:

{
  config = {
 
  
  environment.systemPackages = with pkgs; [
    gitg
    gitui
    gitFull
    git-doc
    github-desktop 
  ];

  };
}