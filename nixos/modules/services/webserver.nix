{ config, pkgs, lib, ... }:

let
  sites = [ "site1.local" "site2.local" ];
  
  mkPhpVirtualHost = siteName: {
    root = "/var/www/${siteName}";
    forceSSL = false;
    enableACME = false;
    locations."/" = {
      index = "index.php";
      tryFiles = "$uri $uri/ /index.php?$query_string";
    };
    locations."~ \\.php$" = {
      extraConfig = ''
        fastcgi_pass unix:/run/phpfpm/www.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include ${pkgs.nginx}/conf/fastcgi_params;
      '';
    };
  };

  virtualHosts = lib.listToAttrs (map (site: lib.nameValuePair site (mkPhpVirtualHost site)) sites);
  tmpfilesRules = [ "d /var/www 0755 www-data www-data" ] ++ 
    (map (site: "d /var/www/${site} 0755 www-data www-data") sites);

in
{
  networking.hosts = {
    "127.0.0.1" = sites;
  };

  users.users.www-data = {
    isSystemUser = true;
    group = "www-data";
    home = "/var/www";
    createHome = true;
  };
  users.groups.www-data = {};

  services.nginx = {
    enable = true;
    user = "www-data";
    group = "www-data";
    
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = virtualHosts;
  };

  systemd.tmpfiles.rules = tmpfilesRules ++ 
    (map (site: "f /var/www/${site}/index.php 0644 www-data www-data - \"<?php phpinfo(); ?>\"") sites);
}