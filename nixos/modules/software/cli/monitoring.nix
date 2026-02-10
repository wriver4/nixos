{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      # productivity
      glow # markdown previewer in terminal
      btop  # replacement of htop/nmon
      nvtopPackages.full # GPU monitoring (works with nouveau)
      iotop # io monitoring
      iftop # network monitoring

      # system call monitoring
      strace # system call monitoring
      ltrace # library call monitoring
      lsof # list open files

      # system tools
      sysstat # sar, iostat, mpstat, pidstat, sadf
      lm_sensors # for `sensors` command
      ethtool # for `ethtool` command
    ];
  };
}
