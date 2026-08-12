{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./password-manager.nix
    ./rclone.nix
  ];
}
