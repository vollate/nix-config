# Justfile for NixOS configuration management
# Usage: just <command>

# Default recipe - show help
default:
    just --list

# Deploy the configuration to the current host
deploy host="${HOST}":
    sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch --flake .#{{host}} --accept-flake-config

debug host="${HOST}":
    sudo nixos-rebuild switch --flake .#{{host}} --accept-flake-config --show-trace

# Update and deploy the configuration
update host="${HOST}":
    nix flake update --accept-flake-config
    sudo nixos-rebuild switch --flake .#{{host}} --accept-flake-config

# Build configuration without deploying
build host="${HOST}":
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel

# Check configuration for errors
check host="${HOST}":
    nix flake check
    nixos-rebuild dry-build --flake .#{{host}}

# Clean old generations and garbage collect
clean:
    sudo nix-collect-garbage -d
    sudo nixos-rebuild switch --flake . # Rebuild bootloader entries

# Format all Nix files
fmt:
    treefmt

# Enter development shell
dev:
    nix develop

# Show flake info
info:
    nix flake show

# Update specific input
update-input input:
    nix flake update {{input}}

# Diff current and new configuration
diff host="${HOST}":
    nixos-rebuild build --flake .#{{host}}
    nix --extra-experimental-features nix-command profile diff-closures --profile /nix/var/nix/profiles/system

# Show system generations
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
rollback:
    sudo nixos-rebuild switch --rollback

# Install using the installation script
install host="${HOST}":
    ./scripts/install.sh {{host}}

# Search for packages
search query:
    nix search nixpkgs {{query}}

# Show package info
info-pkg package:
    nix eval --raw nixpkgs#{{package}}.meta.description

# Test configuration in a VM
test-vm host="${HOST}":
    nixos-rebuild build-vm --flake .#{{host}}
    ./result/bin/run-*-vm
