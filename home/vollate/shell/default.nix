{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./zsh.nix
    ./git.nix
    ./tmux.nix
    ./direnv.nix
  ];
}
