{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      zip
      xz
      unzip
      p7zip
      gzip
      gzrt
      bzip2
    ];
  };
}
