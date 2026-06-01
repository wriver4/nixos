{ config, pkgs, ... }:

{
  config = {   
    programs.starship= {
    enable = true;
    settings = {
      scan_timeout = 100;
      command_timeout = 1000; # in milliseconds 
    };
   };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      interactiveShellInit = ''
        rebuild() {
          sudo nix flake update weaver --flake /home/mark/etc/nixos && \
          sudo nixos-rebuild switch --flake /home/mark/etc/nixos#king
        }
      '';

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