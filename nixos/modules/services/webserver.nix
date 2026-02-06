{ config, pkgs, lib, ... }:

let
  # PHP sites — served from /var/www/<name> with PHP-FPM (add new entries alphabetically)
  sites = [
    "dir.local"
    "newfront.local"
    "oldfront.local"
    "postfixmanager.local"
    "qepton.local"
    "site1.local"
    "site2.local"
    "wbcrm.local"
    "wbdopencart.local"
    "wbdprestashop.local"
    "wbdwebsite.local"
    "wbdwoowebsite.local"
    "wgadmin.local"
    "wgclientsat.local"
    "wgclientwifi.local"
    "wgcrm.local"
    "wgcrmxbesh.local"
    "wgrndadmin.local"
    "wgwebsitenew.local"
    "wgwebsiteold.local"
    "wooduplicate.local"
    "wpduplicate.local"
  ];

  # React sites — served from /var/www/<name> with tryFiles fallback to index.html
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

  # Service sites — proxied via .local domains (dashboard buttons + links)
  serviceSites = [
    { name = "oracle.local"; label = "Oracle XE"; }
    { name = "pgadmin.local"; label = "pgAdmin"; }
    { name = "phpmyadmin.local"; label = "phpMyAdmin"; }
  ];

  # Localhost port services — accessed via localhost:<port> (dashboard buttons + links)
  localhostServices = [
    { port = 5678; label = "n8n"; desc = "Workflow Automation"; }
    { port = 9090; label = "Cockpit"; desc = "System & Container Management"; }
  ];

  # Site links — PHP sites in green (enabled), React in purple
  phpLinks = map (site: ''<li><a class="enabled" href="http://${site}" target="_blank">${site}</a></li>'') sites;
  reactLinks = map (site: ''<li><a style="color:purple;" href="http://${site}" target="_blank">${site}</a></li>'') reactSites;
  allLinks = phpLinks ++ reactLinks;

  dashboardHtml = pkgs.writeText "dashboard.html" ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Localhost Domains and Services</title>
      <style>
        html, body { height: 100%; font-family: georgia; }
        body { display: flex; flex-direction: column; background: #d3d3d3; margin: 10px auto; }
        a { text-decoration: none; color: #000000; }
        #wrap { flex: 1 0 auto; width: 960px; margin: 10px auto; }
        #main { width: 100%; overflow: auto; padding-bottom: 10px; }
        #header { width: 100%; margin: 10px auto; text-align: center; }
        #content { width: 100%; margin: 0 auto; }
        h1, h2, ul { clear: both; }
        ul.pagination { margin: 0 auto; padding: 0; column-count: 2; column-gap: 4px; }
        ul.pagination li:hover { background-color: #FFFFFF; }
        ul.pagination li { padding: 10px; background-color: #A9A9A9; font-size: 24px; color: #ffffff; line-height: 1; width: 95%; margin-bottom: 1px; list-style: none; }
        .enabled { color: green !important; }
        .disabled { color: red !important; }
        .footer { display: inline-flex; }
        .buttons { font-size: 1.5em; margin: 10px; }
        .buttons input { float: right; font-size: .75em; margin: 10px; }
        .legend { font-size: 1.5em; margin: 10px; }
        #pager { text-align: right; padding: 10px; }
        #pager button { padding: 8px 14px; margin: 2px; font-family: georgia; font-size: 18px; border: none; cursor: pointer; background: #A9A9A9; color: #fff; }
        #pager button.active { background: #666; color: #000; }
      </style>
    </head>
    <body>
      <div id="wrap">
        <div id="header">
          <h1>Localhost Domains and Services</h1>
          <div class="buttons">
            <form action="http://phpmyadmin.local" target="_blank" style="display:inline;"><input type="submit" value="phpMyAdmin" style="background:purple;color:white;border:none;cursor:pointer;" /></form>
            <form action="http://pgadmin.local" target="_blank" style="display:inline;"><input type="submit" value="pgAdmin" style="background:purple;color:white;border:none;cursor:pointer;" /></form>
            <form action="http://oracle.local" target="_blank" style="display:inline;"><input type="submit" value="Oracle" style="background:purple;color:white;border:none;cursor:pointer;" /></form>
            <form action="http://localhost:5678" target="_blank" style="display:inline;"><input type="submit" value="n8n" style="background:red;color:white;border:none;cursor:pointer;" /></form>
          </div>
        </div>
        <div class="legend">
          <span style="color:green;">PHP</span>
          &emsp;<span style="color:purple;">React</span>
        </div>
        <div id="main">
          <div id="content">
            <ul class="pagination">
              ${lib.concatStringsSep "\n            " allLinks}
            </ul>
          </div>
          <div id="pager"></div>
          <div style="clear:both;">
            <div class="footer">
              <p>&copy; Copyright by Mark</p>
            </div>
          </div>
        </div>
      </div>
      <script>
        (function() {
          var perPage = 24;
          var items = document.querySelectorAll("ul.pagination li");
          var pager = document.getElementById("pager");
          var pages = Math.ceil(items.length / perPage);
          if (pages <= 1) return;
          function show(p) {
            items.forEach(function(li, i) {
              var visible = (i >= p * perPage && i < (p + 1) * perPage);
              li.style.display = visible ? "" : "none";
            });
            pager.querySelectorAll("button").forEach(function(b, i) {
              b.className = (i === p) ? "active" : "";
            });
          }
          for (var i = 0; i < pages; i++) {
            var btn = document.createElement("button");
            btn.textContent = i + 1;
            btn.onclick = (function(p) { return function() { show(p); }; })(i);
            pager.appendChild(btn);
          }
          show(0);
        })();
      </script>
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