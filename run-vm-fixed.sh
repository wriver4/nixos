#!/usr/bin/env bash
# Fixed VM Runner Script - Handles disk image creation properly

set -e

VM_NAME="nixos-webserver-vm"
DISK_IMAGE="./${VM_NAME}.qcow2"

echo "🚀 Starting NixOS Webserver VM..."
echo "VM disk will be created at: $(pwd)/$DISK_IMAGE"

# Set the environment variable for the VM script
export NIX_DISK_IMAGE="$(pwd)/$DISK_IMAGE"

# Run the VM
echo "🔧 Starting VM..."
exec ./result/bin/run-nixos-webserver-vm-vm

echo "✅ VM started!"
echo ""
echo "🌐 Access points:"
echo "   HTTP:  http://localhost:8080"
echo "   SSH:   ssh root@localhost -p 2222 (password: vmtest123)"
echo "   MySQL: mysql -h localhost -P 3306 -u testuser -p (password: testpass)"
echo ""
echo "🛑 To stop the VM: Ctrl+C in this terminal"