{ pkgs, ... }:
{
  # Nix store optimisation (hard-link deduplication + GC)
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;

  # Weekly nix profile and store GC via nh — keep last 3 generations
  systemd.services.nh-clean = {
    description = "Nix profile and store cleanup via nh";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.unstable.nh}/bin/nh clean all --keep 3";
    };
  };

  systemd.timers.nh-clean = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  # Weekly journal vacuum — proactively reclaim space before the 2G cap is hit
  systemd.services.journal-vacuum = {
    description = "Vacuum systemd journal to 1.5G";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/journalctl --vacuum-size=1500M";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  systemd.timers.journal-vacuum = {
    description = "Weekly journal vacuum";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Weekly npm cache clean (user service — _cacache grows unboundedly)
  systemd.user.services.npm-cache-clean = {
    description = "Clean npm cache";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/sh -c '${pkgs.nodejs}/bin/npm cache clean --force && rm -rf \${HOME}/.npm/_npx/*'";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.npm-cache-clean = {
    description = "Weekly npm cache clean";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Weekly uv cache prune (user service — runs in mark's session)
  systemd.user.services.uv-prune = {
    description = "Prune unused entries from the uv cache";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.uv}/bin/uv cache prune";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.uv-prune = {
    description = "Weekly uv cache prune";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
