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
  ];

  # System basics
  system.stateVersion = "24.11";

  # Essential system packages
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
    sysstat
    htop
    tree
    unzip
    zip
    gnupg
  ];
}
