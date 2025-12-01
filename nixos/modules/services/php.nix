{ config, pkgs, lib, inputs, ... }:

{
  services.phpfpm.pools.www = {
    user = "www-data";
    group = "www-data";
    settings = {
      "listen" = "/run/phpfpm/www.sock";
      "listen.owner" = "www-data";
      "listen.group" = "www-data";
      "listen.mode" = "0660";
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 4;
      "pm.max_requests" = 500;
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/phpfpm 0755 www-data www-data"
  ];

  environment.systemPackages = with pkgs; [
    php84
    php84Packages.composer
    php84Packages.composer-local-repo-plugin
  ];
}