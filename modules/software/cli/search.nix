{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      ripgrep
      fzf
    ];
  };
}
