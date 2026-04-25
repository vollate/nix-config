{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./ai-coding.nix
    ./neovim.nix
    ./jetbrains.nix
    ./rustup.nix
    ./vscode.nix
  ];
}
