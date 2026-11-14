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
    ./disk-maintenance.nix
    ./monitoring.nix
    ./mag-access.nix
  ];
}
