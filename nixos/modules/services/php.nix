{ config, pkgs, lib, inputs, ... }:

let
  phpWithExtensions = pkgs.php84.withExtensions ({ enabled, all }: enabled ++ [
    all.mysqli
    all.mysqlnd
    all.pdo_mysql
    all.mbstring
  ]);
in
{
  services.phpfpm.pools.www = {
    user = "www-data";
    group = "www-data";
    phpPackage = phpWithExtensions;
    phpOptions = ''
      sendmail_path = /run/wrappers/bin/sendmail -t -i
    '';
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
    phpWithExtensions
    php84Packages.composer
    php84Packages.composer-local-repo-plugin
  ];
}