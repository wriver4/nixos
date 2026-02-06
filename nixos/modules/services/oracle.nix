{ config, pkgs, lib, ... }:

{
  # Oracle XE 21c via Docker
  # Web console: http://oracle.local (port 5500 proxied via nginx)
  # Database:    localhost:1521 / XE
  # Default passwords set via ORACLE_PWD environment variable

  virtualisation.oci-containers.containers.oracle-xe = {
    image = "container-registry.oracle.com/database/express:21.3.0-xe";
    ports = [
      "1521:1521"
      "5500:5500"
    ];
    environment = {
      ORACLE_PWD = "oracle";
      ORACLE_CHARACTERSET = "AL32UTF8";
    };
    volumes = [
      "oracle-xe-data:/opt/oracle/oradata"
    ];
  };
}
