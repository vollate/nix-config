{ config, lib, pkgs, ... }:

{
  imports = [ ./zsh.nix ./git.nix ./starship.nix ];
}
