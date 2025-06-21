{ config, lib, pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./firefox.nix
    ./vscode.nix
  ];
} 