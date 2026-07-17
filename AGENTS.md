# Agent Notes

`CLAUDE.md` covers the same ground for Claude Code — keep both files in sync when changing workflow guidance.

## Project Commands

- Run Justfile recipes as `just <command>`.
- Do not pass the host name explicitly to `just` recipes such as `deploy`, `build`, `check`, `debug`, `update`, `diff`, `install`, or `test-vm`.
- The `Justfile` reads the target host from the `HOST` environment variable.
- Format this repository with `just fmt` (runs treefmt → nixfmt); do not run `nix fmt` or `nixfmt` directly.
- Verify changes with `just check` (runs `nix flake check` + dry-build) before any `just deploy`.

Examples:

```bash
just check
just build
just deploy
```

## Git Submodules (required)

`flake.nix` sets `self.submodules = true` and imports `./private/secrets.nix` at eval time. If the submodules are not checked out, **every nix command fails at evaluation**, not just deploys.

- `private/` → `git@github.com:vollate/nix-private.git` — secrets and per-host private modules (e.g. `private/msi-intel-12700/` is imported by `hosts/msi-intel-12700/default.nix`).
- `dot-config/` → `git@github.com:vollate/dot-config.git` — dotfiles symlinked into home by Home Manager modules.

Both are separate git repos. To change files inside them, commit and push **inside the submodule first**, then bump the submodule ref in this repo. Never commit edits to `private/` to this repo.

## Secrets (SOPS)

- Encrypted secrets live in `private/secrets/*.yaml`; recipients are in `.sops.yaml` (admin age key + per-host key derived from the host's SSH ed25519 key via `ssh-to-age`).
- Edit with `nix shell nixpkgs#sops -c sops private/secrets/<host>.yaml`. Decryption needs the admin key at `~/.config/sops/age/keys.txt`.
- Hosts decrypt at activation via sops-nix using `/etc/ssh/ssh_host_ed25519_key`; after adding a recipient to `.sops.yaml`, run `sops updatekeys` on the file.
- Plain `secrets.nix` (non-SOPS, gitignored submodule content) is passed to all modules as the `secrets` specialArg.

## Architecture

- `lib/default.nix` `mkHost` composes: `modules/{base,desktop,development,utility}` + `hosts/<hostname>/` + `users/<username>.nix` + Home Manager (`home/<username>/`) + sops-nix. Modules receive `inputs`, `hostname`, `username`, `desktop`, `secrets` as specialArgs.
- Hosts: `tb-amd-6800h`, `msi-intel-12700`. New hosts must set `nixosVollate.graphicsVendor` ("amd" | "intel" | "nvidia"; option declared in `modules/development/default.nix`) — hardware modules branch on it.
- The repo is expected to live at `~/nix-config`: `home/vollate/develop/neovim.nix` hardcodes that absolute path for an out-of-store symlink.
