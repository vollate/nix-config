{ lib, pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./network.nix
    ./locale.nix
    ./users.nix
    ./nix.nix
    ./proxy.nix
    ./security.nix
    ./ssh.nix
    ./keyboard.nix
  ];

  # Essential system packages
  environment.systemPackages = with pkgs; [
    neovim # Basic editor (may be overridden by overlays)
    wget
    curl
    git
    sysstat
    tree
    unzip
    zip
    gnupg
  ];

  # FHS compatibility for non-NixOS binaries (VSCode Server, dynamic executables)
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
  };
}
