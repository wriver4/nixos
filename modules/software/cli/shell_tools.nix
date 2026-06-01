{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      tmux
      neofetch
      eza
      tree
      bat
      nushell
      jq
    ];
  };
}
