{ config, pkgs, lib, inputs,  ... }:

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
}
