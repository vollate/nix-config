# ❄️ Vollate's NixOS Configuration

> Modular NixOS flake based on [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config).

## Current structure

```txt
nix-config/
├── AGENTS.md
├── Justfile
├── LICENSE
├── README.md
├── flake.nix
├── flake.lock
├── treefmt.toml
├── .gitmodules
├── .sops.yaml
├── users/
├── lib/
├── modules/
│   ├── base/
│   ├── desktop/
│   ├── development/
│   └── utility/
├── hosts/
│   ├── tb-amd-6800h/
│   └── msi-intel-12700/
├── home/
│   └── vollate/
│       ├── programs/
│       ├── desktop/
│       ├── develop/
│       └── shell/
├── overlays/
├── packages/
│   └── pars-cli/
├── scripts/
├── tests/
└── [submodules]
    ├── private/        # git submodule: secrets + host-private config
    └── dot-config/     # git submodule: external dotfiles
```

## How the configuration is composed

- `flake.nix` declares flake inputs and exposes `nixosConfigurations`.
- `lib/default.nix` provides `mkSystem` and `mkHost`:
  - `mkHost` automatically adds `modules/{base,desktop,development,utility}`.
  - `mkSystem` imports:
    - `hosts/<hostname>/`
    - `users/<username>.nix`
    - `sops-nix`
    - Home Manager integration
    - overlay configuration
- `home/vollate/default.nix` is the Home Manager entrypoint for the user and imports:
  - `programs/`
  - `desktop/`
  - `develop/`
  - `shell/`

## Quick start

```bash
# clone (path assumed to be ~/nix-config)
git clone <repo-url> ~/nix-config
cd ~/nix-config

git submodule update --init --recursive
```

> `flake.nix` uses `self.submodules = true`; missing submodules will break evaluation.

## Common workflows

Set target host once via `HOST` (preferred usage):

```bash
export HOST=tb-amd-6800h    # or msi-intel-12700
```

```bash
just check    # run flake checks + dry-build (recommended before deploy)
just build    # build system closure
just deploy   # apply current config
just update   # update flake inputs + switch
just dev      # enter dev shell
just fmt     # format nix files via treefmt
just test-vm  # build and run VM (hosted by nixos-rebuild build-vm)
just diff
just clean
just generations
just rollback
```

Direct deploy syntax is still supported:

```bash
sudo nixos-rebuild switch --flake .#${HOST}
```

## Secrets and submodules

- `private/` and `dot-config/` are Git submodules.
- Secret files are under `private/secrets/*.yaml` and encrypted for recipients in `.sops.yaml`.
- Runtime decryption uses the host private key at `/etc/ssh/ssh_host_ed25519_key`.

Edit host secrets:

```bash
EDITOR=nvim nix shell nixpkgs#sops -c sops private/secrets/msi-intel-12700.yaml
```

Set up or add a new admin key:

```bash
mkdir -p ~/.config/sops/age
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
```

Derive a host age recipient:

```bash
nix shell nixpkgs#ssh-to-age -c sh -c 'ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub'
```

Then re-encrypt keys file:

```bash
nix shell nixpkgs#sops -c sops updatekeys private/secrets/msi-intel-12700.yaml
```

## Extending this repo

### Add a host

1. Create `hosts/<hostname>/` with `default.nix`, `hardware-configuration.nix`, `hardware.nix`, `networking.nix`.
2. Set `nixosVollate.graphicsVendor` in host config (`"amd" | "intel" | "nvidia"`).
3. Add it in `flake.nix` with `myLib.mkHost`.

### Add a module

1. Add a `.nix` module under the relevant `modules/` area.
2. Import it from that category's `default.nix`.
3. For a new top-level category, include it in `mkHost` in `lib/default.nix`.

### Add Home Manager program/settings

1. Add module under `home/vollate/<category>/`.
2. Import it from the matching `default.nix` (`programs/`, `desktop/`, `develop/`, `shell/`).
3. Use official Home Manager options when available.

## References

- [NixOS & Nix Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)

## License

MIT — see [`LICENSE`](LICENSE).
