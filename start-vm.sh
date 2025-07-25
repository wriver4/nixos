#!/usr/bin/env bash
# Simple VM Starter - No MySQL port forwarding to avoid conflicts

set -e

VM_NAME="nixos-webserver-vm"
DISK_IMAGE="./${VM_NAME}.qcow2"

echo "🚀 Starting NixOS Webserver VM..."
echo "VM disk: $(pwd)/$DISK_IMAGE"

# Set the disk image location
export NIX_DISK_IMAGE="$(pwd)/$DISK_IMAGE"

# Clear any existing QEMU options and set only the ports we need
export QEMU_NET_OPTS=""

echo "🔧 Port mappings:"
echo "   HTTP: http://localhost:8080"
echo "   SSH:  ssh root@localhost -p 2222 (password: vmtest123)"
echo "   MySQL: Access from within VM only (port 3306 conflict avoided)"
echo ""
echo "🌐 Test URLs once VM boots:"
echo "   http://localhost:8080/"
echo "   http://localhost:8080/info.php"
echo "   http://localhost:8080/test.php"
echo ""
echo "🛑 To stop: Ctrl+C"
echo ""

# Run the VM
./result/bin/run-nixos-webserver-vm-vm