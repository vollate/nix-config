{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./claude-code.nix
    ./neovim.nix
    ./jetbrains.nix
    ./rustup.nix
    ./vscode.nix
  ];
}
