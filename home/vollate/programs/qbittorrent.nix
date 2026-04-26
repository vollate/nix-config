{ config, pkgs, ... }:

let
  vueTorrentTheme = pkgs.fetchzip {
    url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.32.1/vuetorrent.zip";
    sha256 = "sha256-md6UckHoMhnUAg2Kn3FqvzgEOBvfi8fTaTdbErvU73s=";
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
