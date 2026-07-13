{
  lib,
  config,
  pkgs,
  ...
}:

let
  vueTorrentTheme = pkgs.fetchzip {
    url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.34.0/vuetorrent.zip";
    sha256 = "sha256-1AElVp46YHGpPA/aX5ASPIiMhdiEGDR1Ne2nHnviGY4=";
    stripRoot = false;
  };
in
{
  home.packages = [ pkgs.qbittorrent-enhanced-nox ];

  systemd.user.services.qbittorrent = {
    Unit = {
      Description = "qBittorrent-enhanced Daemon";
      After = [ "network-online.target" ];
    };

    Service = {
      ExecStart = "${pkgs.qbittorrent-enhanced-nox}/bin/qbittorrent-nox";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.file.".local/share/qbittorrent/theme".source = vueTorrentTheme;
}
