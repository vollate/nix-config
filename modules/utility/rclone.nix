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
    { config, lib, ... }:
    let
      rcloneConfigFile = "${config.xdg.configHome}/rclone/rclone.conf";
    in
    lib.mkIf hasRcloneConfig {
      home.activation.installRcloneConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        target=${lib.escapeShellArg rcloneConfigFile}
        source=${lib.escapeShellArg rcloneConfigPath}

        if [[ -L "$target" ]]; then
          run rm -f "$target"
        fi

        if [[ ! -e "$target" ]]; then
          run install -D -m 600 "$source" "$target"
        else
          run chmod 600 "$target"
        fi
      '';

      home.sessionVariables.RCLONE_CONFIG = rcloneConfigFile;
    };
}
