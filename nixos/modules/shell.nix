{ config, pkgs, ... }:

{
  config = {   
    programs.starship= {
    enable = true;
    settings = {
      command_timeout = 1000; # in milliseconds 
    };
   };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch --upgrade --impure";
        ss = "sudo -s";
        mf = "touch ";
        nlg = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
        nsgc = "sudo nix store gc";
        ncg3d = "sudo nix-collect-garbage --delete-older-than 3d";
      }; 
    };
  };
}