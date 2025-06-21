{ config, lib, pkgs, ... }:

{
  # Enable Podman
  virtualisation.podman = {
    enable = true;
    
    # Docker compatibility
    dockerCompat = true;
    
    # Default network
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  # Podman-related packages
  environment.systemPackages = with pkgs; [
    podman-compose
    dive # Container image analyzer
    lazydocker # Terminal UI for containers
  ];
} 