{ config, lib, pkgs, ... }:

{
  # Host-specific networking configuration
  networking = {
    # Enable wake-on-lan
    interfaces.enp3s0.wakeOnLan.enable = true;
    
    # Firewall configuration for this host
    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        22    # SSH
        80    # HTTP
        443   # HTTPS
        # 8080  # Development server
      ];
      allowedUDPPorts = [ ];
    };
    
    # Host-specific DNS settings (if different from default)
    # nameservers = [ "8.8.8.8" "1.1.1.1" ];
  };

  # Enable SSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
} 