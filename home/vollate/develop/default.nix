{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./ai-coding.nix
    ./coding-tools-mcp.nix
    ./neovim.nix
    ./jetbrains.nix
    ./pnpm.nix
    ./rustup.nix
    ./vscode.nix
  ];
}
