{ config, lib, pkgs, hostname, ... }:

{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    
    # Disable firewall by default (can be overridden in host config)
    firewall = {
      enable = lib.mkDefault false;
    };
  };

  # DNS configuration
  networking.nameservers = [
    "223.5.5.5"  # AliDNS
    "119.29.29.29"  # DNSPod
    "8.8.8.8"    # Google DNS
    "1.1.1.1"    # Cloudflare DNS
  ];
} 