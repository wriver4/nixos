{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      ffmpeg_7-full # A complete, cross-platform solution to record, convert and stream audio and video
      clamav # Antivirus engine for detecting trojans, viruses, malware & other malicious threats
      # clamsmtp # A lightweight SMTP filter for ClamAV
      sshfs
      gpu-screen-recorder
      # Support for GTk-4 desktop extension
      imagemagick # A software suite to create, edit, compose, or convert bitmap images
      gjs
      gdk-pixbuf
    ];
  };
}
