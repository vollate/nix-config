{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  hasRcloneConfig = config.sops.secrets ? rclone_config;
  rcloneConfigPath = config.sops.secrets.rclone_config.path;
in
{
  environment.systemPackages = with pkgs; [
    rclone
  ];

  home-manager.users.${username} =
    { config, ... }:
    lib.mkIf hasRcloneConfig {
      xdg.configFile."rclone/rclone.conf".source = config.lib.file.mkOutOfStoreSymlink rcloneConfigPath;
      home.sessionVariables.RCLONE_CONFIG = "${config.xdg.configHome}/rclone/rclone.conf";
    };
}
