{
  config,
  lib,
  pkgs,
  ...
}:

{
  # GTK theme configuration for GTK applications (including WebKitGTK/Wails apps)
  gtk = {
    enable = true;

    # Use Breeze theme to match KDE Plasma
    theme = {
      name = "Breeze";
      package = pkgs.kdePackages.breeze-gtk;
    };

    # Icon theme
    iconTheme = {
      name = "breeze";
      package = pkgs.kdePackages.breeze-icons;
    };

    # Cursor theme
    cursorTheme = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
    };

    # Font configuration
    font = {
      name = "Noto Sans";
      size = 10;
    };

    # GTK2 settings
    gtk2.extraConfig = ''
      gtk-theme-name="Breeze"
      gtk-icon-theme-name="breeze"
      gtk-font-name="Noto Sans 10"
      gtk-cursor-theme-name="breeze_cursors"
      gtk-cursor-theme-size=24
      gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
      gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-button-images=1
      gtk-menu-images=1
      gtk-enable-event-sounds=1
      gtk-enable-input-feedback-sounds=0
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
    '';

    # GTK3 settings
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = false;
      gtk-button-images = true;
      gtk-menu-images = true;
      gtk-enable-animations = true;
      gtk-toolbar-style = "GTK_TOOLBAR_BOTH_HORIZ";
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-decoration-layout = "icon:minimize,maximize,close";
    };

    # GTK4 settings
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = false;
      gtk-decoration-layout = "icon:minimize,maximize,close";
    };
  };

  # Session variables for theme consistency
  home.sessionVariables = {
    # Qt platform theme (use KDE settings for Qt apps)
    QT_QPA_PLATFORMTHEME = "kde";

    # GTK theme variables (helps some apps find themes)
    GTK_THEME = "Breeze";

    # Ensure GTK uses portal for file dialogs
    GTK_USE_PORTAL = "1";
  };

  # Packages needed for GTK theme support
  home.packages = with pkgs; [
    # Theme switching tools
    kdePackages.kde-gtk-config

    # Additional GTK tools
    gsettings-desktop-schemas
    dconf
  ];
}
