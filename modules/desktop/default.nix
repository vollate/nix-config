{ lib, pkgs, desktop ? null, ... }:

{
  imports = [ ./audio.nix ./fonts.nix ./xserver.nix ]
    ++ lib.optionals (desktop == "plasma") [ ./plasma.nix ]
    ++ lib.optionals (desktop == "gnome") [ ./gnome.nix ]
    ++ lib.optionals (desktop == "hyprland") [ ./hyprland.nix ];

  # Common desktop packages
  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
    mpv
    gimp
    libreoffice
    telegram-desktop
    vscode
    # GUI framework dependencies
    gtk3
    webkitgtk
    pkg-config
  ];

  # Enable dconf (required for many desktop applications)
  programs.dconf.enable = true;
}
