# /etc/nixos/cache-cap.nix
#
# Size-capped cache cleanup. Complements systemd-tmpfiles (age-based)
# by enforcing a hard ceiling on total bytes per directory.
#
# Usage:
#   services.cache-cap = {
#     enable = true;
#     interval = "daily";
#     targets = [
#       { path = "/home/mark/.cache";        maxSize = "4G"; user = "mark"; }
#       { path = "/home/mark/.cache/mozilla"; maxSize = "1G"; user = "mark"; }
#       { path = "/var/cache";               maxSize = "2G"; }
#     ];
#   };

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.cache-cap;

  cacheCapBin = pkgs.writeShellApplication {
    name = "cache-cap";
    runtimeInputs = with pkgs; [ coreutils findutils ];
    text = ''
      set -euo pipefail

      if [ "$#" -ne 2 ]; then
        echo "usage: cache-cap <directory> <max-size>" >&2
        exit 2
      fi

      dir="$1"
      cap_human="$2"

      if [ ! -d "$dir" ]; then
        echo "cache-cap: $dir does not exist, skipping" >&2
        exit 0
      fi

      cap_bytes=$(numfmt --from=iec "$cap_human")
      total=0
      deleted=0
      freed=0

      tmpfile=$(mktemp)
      trap 'rm -f "$tmpfile"' EXIT

      while IFS=$'\t' read -r _atime size path; do
        new_total=$((total + size))
        if [ "$new_total" -gt "$cap_bytes" ]; then
          printf '%s\n' "$path" >> "$tmpfile"
          deleted=$((deleted + 1))
          freed=$((freed + size))
        else
          total=$new_total
        fi
      done < <(find "$dir" -type f -printf '%A@\t%s\t%p\n' 2>/dev/null | sort -rn)

      if [ -s "$tmpfile" ]; then
        xargs -d '\n' -a "$tmpfile" rm -f
      fi

      find "$dir" -mindepth 1 -type d -empty -delete 2>/dev/null || true
      freed_human=$(numfmt --to=iec "$freed")
      kept_human=$(numfmt --to=iec "$total")
      echo "cache-cap: dir=$dir cap=$cap_human kept=$kept_human deleted=$deleted freed=$freed_human"
    '';
  };

  targetType = types.submodule {
    options = {
      path = mkOption {
        type = types.str;
        description = "Absolute path to the cache directory to cap.";
        example = "/home/mark/.cache";
      };
      maxSize = mkOption {
        type = types.str;
        description = ''
          Maximum cumulative size of regular files under <literal>path</literal>.
          Accepts IEC suffixes: K, M, G, T (e.g. "2G", "512M").
        '';
        example = "2G";
      };
      user = mkOption {
        type = types.str;
        default = "root";
        description = "User the trim service runs as.";
      };
    };
  };

  # Derive a stable, filesystem-safe unit name from the path.
  unitNameOf = t:
    let
      stripped = removePrefix "/" t.path;
      sanitized = replaceStrings [ "/" "." " " ] [ "-" "-" "-" ] stripped;
    in
      "cache-cap-${sanitized}";
in
{
  options.services.cache-cap = {
    enable = mkEnableOption "size-capped cache directory cleanup";

    interval = mkOption {
      type = types.str;
      default = "daily";
      description = ''
        systemd OnCalendar expression. Accepts "hourly", "daily", "weekly",
        or any valid OnCalendar string like "Mon *-*-* 03:00:00".
      '';
    };

    randomizedDelaySec = mkOption {
      type = types.str;
      default = "30m";
      description = "Jitter applied to the timer to avoid thundering-herd I/O.";
    };

    targets = mkOption {
      type = types.listOf targetType;
      default = [ ];
      description = "List of directories to cap, each with its own size ceiling.";
    };

    package = mkOption {
      type = types.package;
      default = cacheCapBin;
      internal = true;
      description = "The cache-cap script package (exposed for debugging).";
    };
  };

  config = mkIf cfg.enable {
    # Make the binary available for manual runs / debugging.
    environment.systemPackages = [ cfg.package ];

    systemd.services = listToAttrs (map (t: {
      name = unitNameOf t;
      value = {
        description = "Size-cap cache directory ${t.path} at ${t.maxSize}";
        serviceConfig = {
          Type = "oneshot";
          User = t.user;
          ExecStart = ''${cfg.package}/bin/cache-cap ${escapeShellArg t.path} ${escapeShellArg t.maxSize}'';
          Nice = 19;
          IOSchedulingClass = "idle";
          IOSchedulingPriority = 7;
          # Light hardening; do NOT set ProtectHome since user caches live there.
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictSUIDSGID = true;
          LockPersonality = true;
        };
      };
    }) cfg.targets);

    systemd.timers = listToAttrs (map (t: {
      name = unitNameOf t;
      value = {
        description = "Timer: size-cap ${t.path}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.interval;
          Persistent = true;
          RandomizedDelaySec = cfg.randomizedDelaySec;
          AccuracySec = "1m";
        };
      };
    }) cfg.targets);
  };
}