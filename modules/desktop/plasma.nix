{ config, lib, pkgs, ... }:

{
  # Enable KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # KDE-specific packages
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.dolphin
    kdePackages.konsole
    kdePackages.spectacle
    kdePackages.ark
    kdePackages.kwrite
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.kruler
    kdePackages.okular
  ];

  # Enable KDE Connect
  programs.kdeconnect.enable = true;
} 