{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ 
      #./rustdesk.nix
    ];
  environment.systemPackages = with pkgs; [
    # netbird
    pm2 # pm2 start /run/current-system/sw/bin/node-red -- -v
        # sudo env PATH=$PATH:/nix/store/wfxq6w9bkp5dcfr8yb6789b0w7128gnb-nodejs-20.18.1/bin /nix/store/sni4zssnggfnqfz40i92n40vxg6msssw-pm2-5.4.2/lib/node_modules/pm2/bin/pm2 startup systemd -u mark --hp /home/mark
        #PM2][ERROR] Failure when trying to write startup script
        #EROFS: read-only file system, open '/etc/systemd/system/pm2-mark.service'
    nodejs_24
    npm-check
    npm-lockfile-fix
    node2nix
  ];
  services.mysql = {
  enable = true;
  package = pkgs.mariadb_114;
  };

  services.postgresql = {
    enable = true;
    # pgvector: vector similarity search extension used by the Engram service.
    extensions = ps: [ ps.pgvector ];
    ensureDatabases = [ "engram" ];
    ensureUsers = [{
      name = "engram";
      ensureDBOwnership = true;
    }];
    authentication = lib.mkForce ''
      # TYPE  DATABASE  USER     ADDRESS        METHOD
      local   all       all                     peer
      # Engram service connects via TCP loopback — trust avoids password management on dev host
      host    engram    engram   127.0.0.1/32   trust
      host    all       all      127.0.0.1/32   md5
      host    all       all      ::1/128        md5
    '';
  };

  # pgvector is not a trusted extension in the nixpkgs build — only superuser can create it.
  # This hook runs as the postgres superuser after each PostgreSQL start and is idempotent.
  systemd.services.postgresql.postStart = lib.mkAfter ''
    ${config.services.postgresql.package}/bin/psql -d engram -c 'CREATE EXTENSION IF NOT EXISTS vector;'
  '';
}
