# Agent Notes

## Overview

This is a modular NixOS flake configuration based on `ryan4yin/nix-config`. A custom library composes reusable NixOS modules, host-specific configuration, users, Home Manager, overlays, and sops-nix into complete systems.

## Project Commands

- Run Justfile recipes as `just <command>`.
- Do not pass the host name explicitly to `just` recipes such as `deploy`, `build`, `check`, `debug`, `update`, `diff`, `install`, or `test-vm`.
- The `Justfile` reads the target host from the `HOST` environment variable.
- Format this repository with `just fmt` (runs treefmt → nixfmt); do not run `nix fmt` or `nixfmt` directly.
- Verify changes with `just check` (runs `nix flake check` + dry-build) before any `just deploy`.

Common build and deployment commands:

```bash
just check
just build
just deploy
just debug
just update
```

Development and testing commands:

```bash
just dev
just fmt
just test-vm
just diff
```

Maintenance and package commands:

```bash
just clean
just generations
just rollback
just search <query>
just info-pkg <package>
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

### Configuration flow

1. `flake.nix` defines inputs and calls the custom library in `lib/default.nix`.
2. `mkHost` includes the standard `modules/{base,desktop,development,utility}` module groups.
3. `mkSystem` adds `hosts/<hostname>/`, `users/<username>.nix`, overlays, sops-nix, and Home Manager from `home/<username>/`.
4. Host modules provide hardware and networking details and can override shared defaults.
5. Home Manager provides user-level programs, desktop settings, development tools, and shell configuration.

`mkSystem` is the low-level constructor and accepts `hostname`, `username`, `system`, `desktop`, `modules`, `extraModules`, `overlays`, and `specialArgs`. `mkHost` is the normal high-level entry point with the standard module groups included automatically. NixOS and Home Manager modules receive `inputs`, `hostname`, `username`, `desktop`, and `secrets` through special arguments.

### Module layout

- `modules/base/`: boot, networking, locale, users, Nix settings, proxy, security, SSH, and keyboard configuration.
- `modules/desktop/`: audio, fonts, X server settings, and the selected desktop environment.
- `modules/development/`: programming tools, containers, virtualization, monitoring, and development services.
- `modules/utility/`: shared utility services.
- `hosts/<hostname>/`: host imports, generated hardware configuration, manual hardware settings, networking, and optional private modules.
- `home/vollate/`: Home Manager configuration grouped under `programs/`, `desktop/`, `develop/`, and `shell/`.
- `overlays/`: package overlays passed to every host through `mkHost`.

Current hosts are `tb-amd-6800h` and `msi-intel-12700`. New hosts must set `nixosVollate.graphicsVendor` to `"amd"`, `"intel"`, or `"nvidia"`; the option is declared in `modules/development/default.nix` and hardware-aware modules branch on it.

The repository is expected to live at `~/nix-config`: `home/vollate/develop/neovim.nix` uses that absolute path for an out-of-store symlink.

## System Considerations

- System Nix settings use Chinese binary-cache mirrors with the official NixOS and nix-community caches as fallbacks. `flake.nix` also contains a commented template for flake-level mirror settings.
- `programs.nix-ld` is enabled system-wide for non-NixOS dynamically linked programs such as VSCode Server.
- OpenSSH disables root login, enables X11 forwarding and SFTP, keeps remote development sessions alive, and opens its firewall port through `services.openssh.openFirewall`.

## Adding Functionality

### Adding a host

1. Create `hosts/<new-hostname>/`.
2. Generate `hardware-configuration.nix` with `nixos-generate-config`.
3. Add `default.nix`, `hardware.nix`, and `networking.nix`, using an existing host as a template.
4. Set `nixosVollate.graphicsVendor` in the host configuration.
5. Add the host to `nixosConfigurations` in `flake.nix` with `myLib.mkHost`.

### Adding a NixOS module

1. Create the module in the appropriate `modules/` category.
2. Import it from that category's `default.nix`.
3. When adding a new top-level category, include it in `mkHost` in `lib/default.nix`.

### Adding a Home Manager program

1. Create a module in the appropriate directory under `home/vollate/`.
2. Import it from that directory's `default.nix`.
3. Prefer Home Manager program options where available; add packages to `home.packages` when no suitable module exists.

## References

- [NixOS & Nix Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Original ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
