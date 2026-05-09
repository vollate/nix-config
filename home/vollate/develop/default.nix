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
    ./pnpm.nix
    ./rustup.nix
    ./vscode.nix
  ];
}
