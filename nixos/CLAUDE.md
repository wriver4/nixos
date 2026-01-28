# NixOS Configuration Notes

## File Ownership

- All files in `/home/mark/etc/nixos` should be owned by `mark:users`
- The git repo is at `/home/mark/etc` (parent directory)
- `/etc/nixos` is a symlink to `/home/mark/etc/nixos`
- When creating new files, ensure they are owned by `mark:users`
- Git objects in `/home/mark/etc/.git` should also be `mark:users`

## Flake Setup

- Uses NixOS flake with `nixpkgs-unstable` overlay
- Unstable packages accessed via `pkgs.unstable.packageName`
- New module files must be staged in git before `nixos-rebuild` can see them

## Rebuild Commands

```bash
# Stage new files first
git -C /home/mark/etc add nixos/path/to/new/file.nix

# Rebuild
sudo nixos-rebuild switch --flake /home/mark/etc/nixos#king
```
