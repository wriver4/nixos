{ config, pkgs, lib, inputs,  ...}:

{
  config = {
  environment.systemPackages = [
    pkgs.php83
  ];
};
}