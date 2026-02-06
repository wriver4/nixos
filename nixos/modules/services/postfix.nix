{ config, pkgs, lib, ... }:

let
  certDir = "/var/lib/postfix/ssl";
  mapDir = "/var/lib/postfix/maps";
in
{
  services.postfix = {
    enable = true;

    # Enable submission (587) and SMTPS (465)
    enableSubmission = true;
    enableSmtp = true;
    submissionOptions = {
      smtpd_tls_security_level = "encrypt";
      smtpd_sasl_auth_enable = "yes";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "private/auth";
      smtpd_client_restrictions = "permit_sasl_authenticated,reject";
      milter_macro_daemon_name = "ORIGINATING";
    };

    settings.main = {
      myhostname = "king.local";
      mydomain = "local";
      myorigin = "local";
      mydestination = [ "king.local" "localhost.local" "localhost" "local" ];

      # Full Postfix with all protocols
      inet_interfaces = "all";
      inet_protocols = "all";
      mynetworks = [ "127.0.0.0/8" "[::1]/128" ];

      # TLS settings - chain file contains key + cert
      smtpd_tls_chain_files = [ "${certDir}/server.pem" ];
      smtpd_tls_security_level = "may";
      smtpd_tls_auth_only = "yes";
      smtpd_tls_loglevel = "1";
      smtpd_tls_protocols = "!SSLv2,!SSLv3,!TLSv1,!TLSv1.1";
      smtp_tls_security_level = "may";
      smtp_tls_loglevel = "1";
      smtp_tls_protocols = "!SSLv2,!SSLv3,!TLSv1,!TLSv1.1";

      # SASL authentication
      smtpd_sasl_auth_enable = "yes";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "private/auth";
      smtpd_sasl_local_domain = "$myhostname";

      # Sender restrictions using blacklist maps
      smtpd_sender_restrictions = lib.concatStringsSep ", " [
        "check_sender_access hash:${mapDir}/sender_blacklist"
        "check_sender_access hash:${mapDir}/discard_senders"
        "permit"
      ];

      # Anti-spam
      smtpd_helo_required = "yes";
      smtpd_helo_restrictions = lib.concatStringsSep ", " [
        "permit_mynetworks"
        "reject_invalid_helo_hostname"
        "reject_non_fqdn_helo_hostname"
      ];

      smtpd_recipient_restrictions = lib.concatStringsSep ", " [
        "permit_mynetworks"
        "permit_sasl_authenticated"
        "reject_unauth_destination"
      ];

      # Mailbox
      home_mailbox = "Maildir/";
    }; # end settings.main
  };

  # Dovecot for SASL auth and IMAP access
  services.dovecot2 = {
    enable = true;
    enableImap = true;
    sslServerCert = "${certDir}/server.crt";
    sslServerKey = "${certDir}/server.key";
    extraConfig = ''
      service auth {
        unix_listener /var/lib/postfix/queue/private/auth {
          mode = 0660
          user = postfix
          group = postfix
        }
      }
      auth_mechanisms = plain login
      mail_location = maildir:~/Maildir
    '';
  };

  # Generate self-signed TLS cert and create empty blacklist maps
  system.activationScripts.postfixSetup = lib.stringAfter [ "etc" ] ''
    mkdir -p ${certDir} ${mapDir}
    if [ ! -f ${certDir}/server.pem ]; then
      ${pkgs.openssl}/bin/openssl req -new -x509 -days 3650 -nodes \
        -out ${certDir}/server.crt \
        -keyout ${certDir}/server.key \
        -subj "/CN=king.local"
      cat ${certDir}/server.key ${certDir}/server.crt > ${certDir}/server.pem
      chmod 600 ${certDir}/server.key ${certDir}/server.pem
      chmod 644 ${certDir}/server.crt
    fi
    if [ ! -f ${mapDir}/sender_blacklist ]; then
      echo "# sender_blacklist - email addresses to REJECT" > ${mapDir}/sender_blacklist
    fi
    if [ ! -f ${mapDir}/discard_senders ]; then
      echo "# discard_senders - domains to DISCARD" > ${mapDir}/discard_senders
    fi
    ${pkgs.postfix}/bin/postmap ${mapDir}/sender_blacklist
    ${pkgs.postfix}/bin/postmap ${mapDir}/discard_senders
  '';

  environment.systemPackages = with pkgs; [
    mailutils # mail command for testing
  ];
}
