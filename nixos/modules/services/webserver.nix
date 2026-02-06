{ config, pkgs, lib, ... }:

let
  sites = [
    "site1.local"
    "site2.local"
    "dir.local"
    "wpduplicate.local"
    "wooduplicate.local"
    "wgwebsitenew.local"
    "wgwebsiteold.local"
    "qepton.local"
    "newfront.local"
    "oldfront.local"
    "wgrndadmin.local"
    "wgadmin.local"
    "wgsatlient.local"
    "wgwificlient.local"
    "wgcrmxbesh.local"
    "wgcrm.local"
    "wbcrm.local"
    "postfixmanager.local"
  ];

  reactSites = [
    "wgxbesh.local"
  ];

  mkReactVirtualHost = siteName: {
    root = "/var/www/${siteName}";
    forceSSL = false;
    enableACME = false;
    locations."/" = {
      tryFiles = "$uri $uri/ /index.html";
    };
  };

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

  phpmyadmin = pkgs.fetchzip {
    url = "https://files.phpmyadmin.net/phpMyAdmin/5.2.2/phpMyAdmin-5.2.2-all-languages.zip";
    hash = "sha256-zmwPMCVo/FekXFHFHRhvLfrq+Mt4nKoe/4r8d5vQxoQ=";
  };

  phpmyadminConfig = pkgs.writeText "config.inc.php" ''
    <?php
    $cfg['blowfish_secret'] = 'CHANGE_ME_TO_A_RANDOM_32_CHAR_STRING_HERE';
    $i = 0;
    $i++;
    $cfg['Servers'][$i]['auth_type'] = 'cookie';
    $cfg['Servers'][$i]['host'] = 'localhost';
    $cfg['Servers'][$i]['socket'] = '/run/mysqld/mysqld.sock';
    $cfg['Servers'][$i]['compress'] = false;
    $cfg['Servers'][$i]['AllowNoPassword'] = false;
    $cfg['TempDir'] = '/tmp/phpmyadmin';
  '';

  phpmyadminRoot = pkgs.runCommand "phpmyadmin-configured" {} ''
    cp -r ${phpmyadmin} $out
    chmod -R u+w $out
    cp ${phpmyadminConfig} $out/config.inc.php
  '';

  virtualHosts = lib.listToAttrs (map (site: lib.nameValuePair site (mkPhpVirtualHost site)) sites)
    // lib.listToAttrs (map (site: lib.nameValuePair site (mkReactVirtualHost site)) reactSites)
    // {
    "pgadmin.local" = {
      forceSSL = false;
      enableACME = false;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5050";
        proxyWebsockets = true;
      };
    };
    "oracle.local" = {
      forceSSL = false;
      enableACME = false;
      locations."/" = {
        proxyPass = "https://127.0.0.1:5500";
        proxyWebsockets = true;
      };
    };
    "phpmyadmin.local" = {
      root = "${phpmyadminRoot}";
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
  };

  tmpfilesRules = [ "d /var/www 0775 www-data www-data -" ] ++
    (map (site: "d /var/www/${site} 0775 www-data www-data -") (sites ++ reactSites));

in
{
  networking.hosts = {
    "127.0.0.1" = sites ++ reactSites ++ [ "phpmyadmin.local" "pgadmin.local" "oracle.local" ];
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
    (map (site: "f /var/www/${site}/index.php 0664 mark www-data - \"<?php echo '<h1>${site}</h1>'; phpinfo(); ?>\"") sites) ++
    (map (site: "f /var/www/${site}/index.html 0664 mark www-data - \"<!DOCTYPE html><html><head><title>${site}</title></head><body><h1>${site}</h1><p>React site ready</p></body></html>\"") reactSites) ++
    [ "d /tmp/phpmyadmin 0770 www-data www-data -" ] ++
    [ "f /var/lib/pgadmin/initial-password 0600 pgadmin pgadmin - changeme" ];

  services.pgadmin = {
    enable = true;
    initialEmail = "admin@local.dev";
    initialPasswordFile = "/var/lib/pgadmin/initial-password";
  };

  system.activationScripts.fixWebserverPerms = lib.stringAfter ["users"] ''
    chmod 0775 /var/www
    ${lib.concatStringsSep "\n" (map (site: "chmod 0775 /var/www/${site}") (sites ++ reactSites))}
    ${lib.concatStringsSep "\n" (map (site: "chmod 0664 /var/www/${site}/index.php 2>/dev/null || true") sites)}
  '';
}