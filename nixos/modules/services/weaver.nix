{ config, pkgs, ... }:

{
  imports = [
    /home/mark/Projects/active/fabrick-weaver-project/code/nixos/default.nix
  ];

  config = {
    services.weaver.enable = true;
  };
}
