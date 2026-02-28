{
  config,
  lib,
  pkgs,
  ...
}:

{
  # imports = [ ./gtk.nix ];
  # Desktop applications
  home.packages = with pkgs; [
    # File manager
    kdePackages.dolphin

    # Browser
    firefox
    google-chrome

    # Media
    vlc
    gimp

    # Office
    onlyoffice-desktopeditors

    # System tools
    kdePackages.ark
    kdePackages.kate
    kdePackages.konsole
    kdePackages.yakuake
    kdePackages.kgpg
  ];

  # Desktop environment specific settings
  # These can be customized based on your desktop environment
}
