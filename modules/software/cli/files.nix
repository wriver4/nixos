{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      mc           # terminal file manager, browses archives without extracting
      atool        # universal archive list/extract wrapper
      dua          # fast interactive disk usage analyzer
      fdupes       # find and remove duplicate files
    ];
  };
}
