#!/usr/bin/env bash
# VM Runner Script - Creates writable disk in current directory

set -e

VM_NAME="nixos-webserver-vm"
DISK_IMAGE="./${VM_NAME}.qcow2"

echo "🚀 Starting NixOS Webserver VM..."
echo "VM disk will be created at: $DISK_IMAGE"

# Create the disk image in current directory if it doesn't exist
if [ ! -f "$DISK_IMAGE" ]; then
    echo "📀 Creating VM disk image..."
    qemu-img create -f qcow2 "$DISK_IMAGE" 8G
fi

# Run the VM with the local disk image
echo "🔧 Starting VM with local disk..."
exec ./result/bin/run-nixos-vm

echo "✅ VM started successfully!"
echo ""
echo "🌐 Access points:"
echo "   HTTP:  http://localhost:8080"
echo "   SSH:   ssh root@localhost -p 2222 (password: vmtest123)"
echo "   MySQL: mysql -h localhost -P 3306 -u testuser -p (password: testpass)"
echo ""
echo "🛑 To stop the VM: Ctrl+C in this terminal"