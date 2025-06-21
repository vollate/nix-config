{ config, lib, pkgs, ... }:

{
  # Desktop applications
  home.packages = with pkgs; [
    # File manager
    kdePackages.dolphin
    
    # Browser
    firefox
    
    # Media
    vlc
    gimp
    
    # Office
    onlyoffice-bin
    
    # System tools
    kdePackages.ark
    kdePackages.kate
    kdePackages.konsole
  ];

  # Desktop environment specific settings
  # These can be customized based on your desktop environment
} 