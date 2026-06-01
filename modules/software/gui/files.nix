{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      unstable.meld  # visual diff and merge
      dupeguru       # duplicate file finder
      grsync         # GUI front-end for rsync
    ];
  };
}
