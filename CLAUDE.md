# NixOS Configuration Notes

## File Ownership

- All files in `<your-nixos-path>` should be owned by `<your-user>:users`
- The git repo can live at any path — `/etc/nixos` can be a symlink into it
- When creating new files, ensure they are owned by your user, not root
- Git objects should also be owned by your user

## Flake Setup

- Uses NixOS flake with `nixpkgs-unstable` overlay
- Unstable packages accessed via `pkgs.unstable.packageName`
- New module files must be staged in git before `nixos-rebuild` can see them

## Rebuild Commands

```bash
# Stage new files first (path: inputs only see git-tracked content)
git add path/to/new/file.nix

# Rebuild
./rebuild.sh

# If you use local path: inputs in flake.nix, rebuild.sh refreshes their
# narHash before running nixos-rebuild. Never call nixos-rebuild switch
# directly — it will fail on a stale hash if a path: input has changed.
```
