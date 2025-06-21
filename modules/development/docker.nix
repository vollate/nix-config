{ config, lib, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    
    # Use Docker Compose v2
    daemon.settings = {
      features = {
        buildkit = true;
      };
    };
  };

  # Docker-related packages
  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
    dive # Docker image analyzer
    lazydocker # Terminal UI for Docker
  ];

  # Enable Docker rootless mode (optional)
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };
} 