#!/usr/bin/env bash
# VM Runner with Alternative Ports - Avoids port conflicts

set -e

VM_NAME="nixos-webserver-vm"
DISK_IMAGE="./${VM_NAME}.qcow2"

echo "🚀 Starting NixOS Webserver VM with alternative ports..."
echo "VM disk will be created at: $(pwd)/$DISK_IMAGE"

# Set the environment variable for the VM script
export NIX_DISK_IMAGE="$(pwd)/$DISK_IMAGE"

# Override QEMU network options to use different ports
export QEMU_NET_OPTS=",hostfwd=tcp::8080-:80,hostfwd=tcp::8443-:443,hostfwd=tcp::3307-:3306,hostfwd=tcp::2222-:22"

echo "🔧 Starting VM with port mappings:"
echo "   HTTP:  localhost:8080 -> VM:80"
echo "   HTTPS: localhost:8443 -> VM:443"
echo "   MySQL: localhost:3307 -> VM:3306 (changed from 3306 to avoid conflicts)"
echo "   SSH:   localhost:2222 -> VM:22"
echo ""

# Run the VM
exec ./result/bin/run-nixos-webserver-vm-vm