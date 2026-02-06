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
    "localhost" = {
      root = "/var/www/localhost";
      forceSSL = false;
      enableACME = false;
      default = true;
      locations."/" = {
        index = "index.html";
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

  serviceSites = [
    { name = "phpmyadmin.local"; label = "phpMyAdmin"; }
    { name = "pgadmin.local"; label = "pgAdmin"; }
    { name = "oracle.local"; label = "Oracle XE"; }
  ];

  localhostServices = [
    { port = 5678; label = "n8n"; desc = "Workflow Automation"; }
  ];

  allSiteLinks = lib.concatStringsSep "\n" (
    (map (site: ''<li><a href="http://${site}">${site}</a></li>'') sites) ++
    (map (site: ''<li><a href="http://${site}">${site}</a> <span class="tag react">React</span></li>'') reactSites) ++
    (map (s: ''<li><a href="http://${s.name}">${s.label}</a> <span class="tag service">${s.name}</span></li>'') serviceSites) ++
    (map (s: ''<li><a href="http://localhost:${toString s.port}">${s.label}</a> <span class="tag localhost">:${toString s.port}</span> <span class="tag service">${s.desc}</span></li>'') localhostServices)
  );

  dashboardHtml = pkgs.writeText "dashboard.html" ''
    <!DOCTYPE html>
    <html>
    <head>
      <title>Dev Server Dashboard</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; max-width: 800px; margin: 40px auto; padding: 0 20px; background: #1a1a2e; color: #e0e0e0; }
        h1 { color: #00d4ff; border-bottom: 2px solid #00d4ff; padding-bottom: 10px; }
        h2 { color: #7b68ee; margin-top: 30px; }
        ul { list-style: none; padding: 0; }
        li { padding: 8px 12px; margin: 4px 0; background: #16213e; border-radius: 6px; }
        li:hover { background: #1a2747; }
        a { color: #00d4ff; text-decoration: none; font-size: 1.1em; }
        a:hover { text-decoration: underline; }
        .tag { font-size: 0.75em; padding: 2px 8px; border-radius: 10px; margin-left: 8px; }
        .tag.react { background: #61dafb22; color: #61dafb; border: 1px solid #61dafb55; }
        .tag.service { background: #7b68ee22; color: #7b68ee; border: 1px solid #7b68ee55; }
        .tag.localhost { background: #ff634722; color: #ff6347; border: 1px solid #ff634755; }
        .info { color: #888; font-size: 0.9em; margin-top: 30px; }
      </style>
    </head>
    <body>
      <h1>Dev Server Dashboard</h1>
      <h2>Sites</h2>
      <ul>
        ${allSiteLinks}
      </ul>
      <p class="info">king.local &mdash; ${toString (builtins.length sites)} PHP sites, ${toString (builtins.length reactSites)} React sites, ${toString (builtins.length serviceSites)} services</p>
    </body>
    </html>
  '';

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

  systemd.tmpfiles.rules = [ "d /var/www/localhost 0775 www-data www-data -" ] ++ tmpfilesRules ++
    (map (site: "f /var/www/${site}/index.php 0664 mark www-data - \"<?php echo '<h1>${site}</h1>'; phpinfo(); ?>\"") sites) ++
    (map (site: "f /var/www/${site}/index.html 0664 mark www-data - \"<!DOCTYPE html><html><head><title>${site}</title></head><body><h1>${site}</h1><p>React site ready</p></body></html>\"") reactSites) ++
    [ "d /tmp/phpmyadmin 0770 www-data www-data -" ] ++
    [ "f /var/lib/pgadmin/initial-password 0600 pgadmin pgadmin - changeme" ];

  services.pgadmin = {
    enable = true;
    initialEmail = "admin@local.dev";
    initialPasswordFile = "/var/lib/pgadmin/initial-password";
  };

  system.activationScripts.deployDashboard = lib.stringAfter ["etc"] ''
    mkdir -p /var/www/localhost
    cp ${dashboardHtml} /var/www/localhost/index.html
    chmod 0644 /var/www/localhost/index.html
    chown www-data:www-data /var/www/localhost/index.html 2>/dev/null || true
  '';

  system.activationScripts.fixWebserverPerms = lib.stringAfter ["users"] ''
    chmod 0775 /var/www 2>/dev/null || true
    ${lib.concatStringsSep "\n" (map (site: "chmod 0775 /var/www/${site} 2>/dev/null || true") (sites ++ reactSites))}
    ${lib.concatStringsSep "\n" (map (site: "chmod 0664 /var/www/${site}/index.php 2>/dev/null || true") sites)}
  '';
}