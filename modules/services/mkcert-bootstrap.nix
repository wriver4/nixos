{ config, lib, pkgs, ... }:

let
  # Auto-discover declarative vhosts. Drop "default_server" markers and
  # IP/numeric names — keep only real hostnames.
  vhostNames = lib.filter
    (n: n != "_" && n != "localhost" && !(lib.hasPrefix "127." n))
    (lib.attrNames config.services.nginx.virtualHosts);

  # SAN list for mkcert. Wildcard stays for ad-hoc vhost-add sites;
  # explicit names give Node clients (mcp-remote etc.) something they'll honor.
  sanList = [ "*.local" "localhost" "127.0.0.1" "::1" ] ++ vhostNames;

  certPath = "/var/lib/mkcert/local.pem";
  keyPath  = "/var/lib/mkcert/local-key.pem";
  sanFile  = "/var/lib/mkcert/.sans";          # newline-separated, sorted
  desiredSans = lib.concatStringsSep "\n"
    (lib.unique (lib.sort (a: b: a < b) sanList));

  mkcertBin = "${pkgs.mkcert}/bin/mkcert";
  opensslBin = "${pkgs.openssl}/bin/openssl";
in {
  systemd.services.mkcert-bootstrap = {
    description = "Generate / refresh shared mkcert wildcard cert when the SAN list changes";
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail
      umask 027

      install -d -m 0755 /var/lib/mkcert
      install -d -m 0700 /var/lib/mkcert/CA
      export CAROOT=/var/lib/mkcert/CA

      # First-run bootstrap: seed the new CAROOT from root's existing CA if present,
      # otherwise let mkcert create a fresh one. After this, /var/lib/mkcert/CA is canonical.
      if [ ! -f "$CAROOT/rootCA.pem" ]; then
        if [ -f /root/.local/share/mkcert/rootCA.pem ] && [ -f /root/.local/share/mkcert/rootCA-key.pem ]; then
          echo "mkcert: seeding /var/lib/mkcert/CA from /root/.local/share/mkcert/"
          cp /root/.local/share/mkcert/rootCA.pem     "$CAROOT/rootCA.pem"
          cp /root/.local/share/mkcert/rootCA-key.pem "$CAROOT/rootCA-key.pem"
          chmod 0600 "$CAROOT/rootCA-key.pem"
          chmod 0644 "$CAROOT/rootCA.pem"
        else
          echo "mkcert: no existing CA found, mkcert will create a fresh one."
        fi
      fi

      DESIRED=$(cat <<'EOF'
${desiredSans}
EOF
      )

CURRENT=""
      [ -f "${sanFile}" ] && CURRENT=$(cat "${sanFile}")

      if [ -f "${certPath}" ] && [ "$DESIRED" = "$CURRENT" ]; then
        echo "mkcert: SAN list unchanged, cert is up to date."
        exit 0
      fi

      echo "mkcert: SAN list differs (or cert missing) — regenerating."
      echo "Desired SANs:"
      echo "$DESIRED" | sed 's/^/  /'

      ARGS=()
      while IFS= read -r line; do
        [ -n "$line" ] && ARGS+=("$line")
      done <<< "$DESIRED"

      ${mkcertBin} \
        -cert-file "${certPath}" \
        -key-file  "${keyPath}" \
        "''${ARGS[@]}"

      chown root:www-data "${certPath}" "${keyPath}"
      chmod 0640          "${certPath}" "${keyPath}"

      echo "$DESIRED" > "${sanFile}"
      chmod 0644 "${sanFile}"

      echo "mkcert: cert regenerated. Verify:"
      ${opensslBin} x509 -in "${certPath}" -noout -ext subjectAltName | sed 's/^/  /'

      if ${pkgs.systemd}/bin/systemctl is-active --quiet nginx.service; then
        ${pkgs.systemd}/bin/systemctl reload --no-block nginx.service || true
      fi
    '';
  };

  # Re-run the service on every nixos-rebuild switch. Idempotent thanks
  # to the SAN-diff guard above.
  system.activationScripts.mkcertBootstrapTrigger = {
    text = ''
      if [ -d /run/systemd/system ]; then
        ${pkgs.systemd}/bin/systemctl restart mkcert-bootstrap.service || true
      fi
    '';
    deps = [ ];
  };
}