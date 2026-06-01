# NixOS Configuration — Operations Guide

> NixOS declarative config for a primary development workstation / homelab host.
> Single-user, x86_64, flake-based, `nixpkgs-unstable` overlay.

---

## What This Config Manages

### AI / LLM Stack
Local inference and memory services — embedding sidecar, generation sidecar, knowledge graph API, vector search, and a developer ops UI. All run as systemd services with sops-nix secrets.

### Development Infrastructure
PostgreSQL with pgvector, MySQL/MariaDB, Oracle XE (Docker), PHP-FPM, nginx with per-project vhosts, Postfix/Dovecot for local mail, n8n workflow automation.

### Desktop
GNOME with extensions, AppImage + Flatpak support, full GUI and CLI software stacks.

### Virtualization
Docker, Podman, libvirtd/QEMU/virt-manager, MicroVM host networking.

### Maintenance
Nix store GC, journal vacuum, store optimization — all on systemd timers.

---

## Prerequisites

- NixOS 25.x with flakes enabled
- `sops-nix` for secrets management (age key derived from SSH host key)
- `mkcert` root CA for local TLS (cert in `secrets/mkcert-rootCA.pem`)

---

## How to Use This Config

### 1. Fork and clone

```bash
git clone git@github.com:wriver4/nixos.git
cd nixos
```

### 2. Fill in the placeholders

Search for `<your-*>` in the config — these are the values stripped from this public mirror:

| Placeholder | Where | What to set |
|-------------|-------|-------------|
| `<your-hostname>` | `modules/hosts/*.nix` | Your machine's hostname |
| `<your-trust-ip>` | `modules/hosts/*.nix` | Static IP on your LAN |
| `<your-gateway>` | `modules/hosts/*.nix` | Router/gateway IP |
| `<your-dev-ip>` | `modules/hosts/*.nix` | Secondary NIC IP (if applicable) |
| `<your-dns-ip>` | `modules/hosts/*.nix` | Local DNS resolver (or `1.1.1.1`) |
| `<your-domain>` | `modules/hosts/*.nix` | Local search domain (e.g. `home.local`) |
| `<your-mac-address>` | `modules/hosts/*.nix` | NIC MAC for NetworkManager profile |
| `<your-ssh-public-key>` | `modules/users.nix` | Your SSH public key |
| `<your-cache-public-key>` | `configuration.nix` | Nix binary cache signing key (or remove) |
| `<your-nix-cache-url>` | `configuration.nix` | Private Nix cache URL (or remove) |

### 3. Customize the module list

`configuration.nix` imports the module tree. Comment out anything you don't need — the AI/LLM stack, Oracle, postfix, etc. are all optional modules.

### 4. Set up secrets

Secrets use [sops-nix](https://github.com/Mic92/sops-nix) with an age key derived from the host's SSH ed25519 key:

```bash
# Generate age key from SSH host key
ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | sudo tee /var/lib/sops-nix/key.txt
```

Update `.sops.yaml` with your own age recipient key.

### 5. Rebuild

```bash
git add .
./rebuild.sh
```

---

## Structure

```
modules/
  hosts/        # Per-host network + boot config
  services/     # Systemd service modules (AI stack, DBs, web server, etc.)
  software/     # Package lists — cli/ and gui/
  system/       # PKI, system-level config
  users.nix     # User account, SSH keys, sudo rules
  common.nix    # Nix settings, overlays, shared imports
configuration.nix  # Top-level imports
flake.nix          # Inputs + nixosConfigurations
rebuild.sh         # Rebuild wrapper (updates path: inputs first)
secrets/           # sops-nix encrypted secrets + mkcert root CA
```

---

## Notes

- `rebuild.sh` updates local `path:` flake inputs before switching — always use it instead of calling `nixos-rebuild` directly
- New `.nix` files must be `git add`-ed before they're visible to the flake evaluator
- `secrets/mkcert-rootCA.pem` is the public root cert for local TLS — safe to commit, no private key
