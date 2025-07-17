#!/usr/bin/env bash
# Restore script created on Thu Jul 17 03:42:40 PM EDT 2025
echo "Restoring NixOS configuration from backup..."
sudo cp -r "/etc/nixos/webserver-backups/20250717-154237"/* "/etc/nixos/"
sudo rm "/etc/nixos/restore.sh"  # Remove this script
echo "Configuration restored. Run 'sudo nixos-rebuild switch' to apply."
