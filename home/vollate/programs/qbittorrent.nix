{ config, pkgs, ... }:

let
  # 纯 Nix 方式：自动从 GitHub 拉取 VueTorrent 主题包
  vueTorrentTheme = pkgs.fetchzip {
    url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.31.3/vuetorrent.zip";
    sha256 = "sha256-mthdc2pXLKTjDv7iTxbwFJuT/lHTQcT1QtzxaZFuXBo=";
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
