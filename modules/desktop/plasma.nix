{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";

  # Auto-login configuration
  services.displayManager.autoLogin = {
    enable = true;
    user = "vollate";
  };

  services.displayManager.sddm.settings.General.DisplayServer = "wayland";

  environment.systemPackages = with pkgs.kdePackages; [
    pkgs.wl-clipboard
    kate
    dolphin
    konsole
    spectacle
    ark
    yakuake
    kcolorchooser
    okular
    kde-gtk-config
  ];
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
  ];

  programs.kdeconnect.enable = true;
}
