{
  lib,
  config,
  pkgs,
  hostname,
  ...
}:

let
  vueTorrentTheme = pkgs.fetchzip {
    url = "https://github.com/VueTorrent/VueTorrent/releases/download/v2.34.0/vuetorrent.zip";
    sha256 = "sha256-1AElVp46YHGpPA/aX5ASPIiMhdiEGDR1Ne2nHnviGY4=";
    stripRoot = false;
  };

  waitForHdd0 = pkgs.writeShellScript "qbittorrent-wait-for-hdd0" ''
    # This is a user service; system-manager mount dependencies cannot order it.
    # Check the exact mountpoint, filesystem UUID and subvolume, not just /HDD0's existence.
    echo "Waiting for the HDD0 current subvolume to be mounted at /HDD0..."
    until [ "$(${pkgs.util-linux}/bin/findmnt --raw --noheadings --mountpoint /HDD0 --output UUID,FSROOT || true)" = "fe687bf7-13bb-4e2c-bd26-f944efba5291 /current" ]; do
      ${pkgs.coreutils}/bin/sleep 2
    done
    echo "HDD0 is mounted; starting qBittorrent."
  '';
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
    }
    // lib.optionalAttrs (hostname == "msi-intel-12700") {
      ExecStartPre = "${waitForHdd0}";
      # A missing/slow disk must leave the daemon waiting, never start without it.
      TimeoutStartSec = "infinity";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.file.".local/share/qbittorrent/theme".source = vueTorrentTheme;
}
