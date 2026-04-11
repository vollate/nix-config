{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./firefox.nix
    ./gpg.nix
    ./aria2.nix
    ./mpv.nix
    ./qbittorrent.nix
    ./flameshot.nix
  ];
}
