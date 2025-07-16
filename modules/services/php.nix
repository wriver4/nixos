{ config, pkgs, lib, inputs,  ...}:

{
  config = {
  environment.systemPackages = with pkgs; [
    php84
    php84Packages.composer
    php84Packages.composer-local-repo-plugin
  ];
};
}