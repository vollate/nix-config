{ config, lib, pkgs, inputs, ... }:

let
  # Generate a unique hash config file in nix store
  singboxConfig = pkgs.writeText "sing-box-config.json" 
    (builtins.readFile "${inputs.private}/singbox/config.json");
in
{
  # Load the TUN kernel module, required for sing-box to create TUN interfaces.
  boot.kernelModules = [ "tun" ];

  # Add sing-box related packages.
  # This includes the core service and the GUI application.
  environment.systemPackages = with pkgs;
    [
      sing-box
      gui-for-singbox
    ];

  # Systemd service disabled - using gui-for-singbox instead
  # systemd.services.sing-box = {
  #   description = "sing-box proxy service";
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     WorkingDirectory = "/var/lib/sing-box";
  #     ExecStart = "${pkgs.sing-box}/bin/sing-box run -c ${singboxConfig}";
  #     Restart = "on-failure";
  #     RestartSec = 5;
  #     User = "root";
  #     Group = "root";
  #
  #     NoNewPrivileges = false;
  #     ProtectSystem = "strict";
  #     ProtectHome = true;
  #     ReadWritePaths = [ "/var/lib/sing-box" "/tmp" ];
  #     PrivateTmp = true;
  #
  #     AmbientCapabilities = [
  #       "CAP_NET_ADMIN"
  #       "CAP_NET_BIND_SERVICE"
  #       "CAP_NET_RAW"
  #     ];
  #     CapabilityBoundingSet = [
  #       "CAP_NET_ADMIN"
  #       "CAP_NET_BIND_SERVICE"
  #       "CAP_NET_RAW"
  #     ];
  #
  #     PrivateNetwork = false;
  #     PrivateDevices = false;
  #   };
  # };

  # Create state directory with proper permissions (still needed for GUI)
  systemd.tmpfiles.rules = [
    "d /var/lib/sing-box 0755 root root -"
  ];

  # Add the TUN interface to the firewall's trusted interfaces to allow traffic.
  networking.firewall.trustedInterfaces = [ "Sing-Box" ];
  
  # Enable IP forwarding for TUN interface
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # DNS configuration optimized for sing-box TUN mode
  # Use TUN interface gateway as primary DNS for DNS hijacking
  networking.nameservers = [
    "172.18.0.1"    # TUN interface gateway (sing-box will handle DNS routing)
    "223.5.5.5"     # AliDNS fallback 
    "119.29.29.29"  # DNSPod fallback
  ];

  # Disable systemd-resolved to avoid DNS conflicts
  services.resolved.enable = false;
  
  # Ensure NetworkManager uses the specified DNS servers
  networking.networkmanager.dns = "none";
}
