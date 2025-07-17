#!/bin/bash
# Restore script created on Thu Jul 17 02:54:31 PM EDT 2025
echo "Restoring NixOS configuration from backup..."
sudo cp -r "/etc/nixos/webserver-backups/20250717-145428"/* "/etc/nixos/"
sudo rm "/etc/nixos/restore.sh"  # Remove this script
echo "Configuration restored. Run 'sudo nixos-rebuild switch' to apply."
