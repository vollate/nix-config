{ config, lib, pkgs, ... }:

{
  # Programming languages and tools
  environment.systemPackages = with pkgs; [
    # Python
    python3
    python3Packages.pip
    python3Packages.virtualenv

    # Node.js
    nodejs
    nodePackages.pnpm

    # Rust
    rustc
    cargo
    rustfmt
    clippy
    cargo-cache

    # Go
    go

    # C/C++
    gcc
    clang
    gdb
    lldb
    clang-tools

    # Java
    jdk21
    maven
    gradle

    # Haskell
    # ghc
    # cabal-install
    # stack

    # Nix
    nil # Nix language server
    nixfmt-classic
    nixpkgs-fmt

    # Web development
    deno
    bun

    # Database tools
    sqlite
    postgresql
    mysql80

    # Container tools
    podman
    buildah
    skopeo

    # VSCode Server dependencies
    wget
    unzip

    # Build tools
    gnumake
    just
    cmake
    ninja
    autoconf
    automake
  ];

  # Enable programming services
  services = {
    # PostgreSQL
    postgresql = {
      enable = lib.mkDefault false;
      package = pkgs.postgresql_15;
    };

    # MySQL
    mysql = {
      enable = lib.mkDefault false;
      package = pkgs.mysql80;
    };
  };
}
