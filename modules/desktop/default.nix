{ lib, pkgs, desktop ? null, ... }:

{
  imports = [
    ./audio.nix
    ./fonts.nix
    ./xserver.nix
  ] ++ lib.optionals (desktop == "plasma") [
    ./plasma.nix
  ] ++ lib.optionals (desktop == "gnome") [
    ./gnome.nix
  ] ++ lib.optionals (desktop == "hyprland") [
    ./hyprland.nix
  ];

  # Common desktop packages
  environment.systemPackages = with pkgs; [
    firefox
    chromium
    thunderbird
    mpv
    gimp
    libreoffice
    telegram-desktop
    discord
    vscode
    obsidian
  ];

  # Enable dconf (required for many desktop applications)
  programs.dconf.enable = true;
} 