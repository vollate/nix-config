{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./rclone.nix
  ];
}
