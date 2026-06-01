#!/usr/bin/env bash
# Rebuild king. Refreshes the weaver path: input first — the narHash in
# flake.lock goes stale whenever the weaver source tree changes, so
# 'nixos-rebuild switch' alone fails until the lock is updated.
set -e

FLAKE=/home/mark/etc/nixos

echo "Updating local path: inputs..."
sudo nix flake update weaver engram --flake "$FLAKE"

echo "Committing and pushing flake.lock..."
sudo -u mark git -C /home/mark/etc add nixos/flake.lock
sudo -u mark git -C /home/mark/etc diff --cached --quiet || sudo -u mark git -C /home/mark/etc commit -m "flake lock"
sudo -u mark git -C /home/mark/etc push

echo "Rebuilding..."
sudo nixos-rebuild switch --flake "$FLAKE#king"
