{
  lib,
  pkgs,
  desktop ? null,
  ...
}:

{
  imports = [
    ./audio.nix
    ./fonts.nix
    ./xserver.nix
  ]
  ++ lib.optionals (desktop == "plasma") [ ./plasma.nix ]
  ++ lib.optionals (desktop == "gnome") [ ./gnome.nix ]
  ++ lib.optionals (desktop == "hyprland") [ ./hyprland.nix ];

  # Enable Firefox via NixOS module
  programs.firefox.enable = true;

  # Common desktop packages
  environment.systemPackages = with pkgs; [
    thunderbird
    mpv
    gimp
    telegram-desktop
    pkg-config

    # Image format libraries (needed by many desktop apps)
    libpng
    libjpeg
    libwebp
    libtiff
    giflib
    libavif
    libjxl

    # Image processing libraries
    imagemagick
    graphicsmagick
    libdecor

    boost
    cairo
    pango
    glib
    gsettings-desktop-schemas
  ];

  # Enable dconf (required for many desktop applications)
  programs.dconf.enable = true;

  # Ensure pixbuf loaders are available
  environment.pathsToLink = [ "/lib/gdk-pixbuf-2.0" ];

  # Wayland session variables (Arch KDE session sets these automatically)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Chromium/Electron Wayland support
    QT_QPA_PLATFORM = "wayland;xcb"; # Qt apps prefer Wayland, fallback to X11
    GDK_BACKEND = "wayland,x11"; # GTK apps prefer Wayland, fallback to X11
    SDL_VIDEODRIVER = "wayland";
  };

  # XDG Desktop Portal (required for Wayland applications)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
    # Explicitly configure portal backends (Arch does this via session startup)
    config = {
      common = {
        default = [
          "kde"
          "gtk"
        ];
      };
    };
  };
}
