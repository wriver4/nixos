{ config, pkgs, ... }:


{
  config = {
   security.pki.certificateFiles = [ ../../secrets/mkcert-rootCA.pem ];
  };
}