{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Load the TUN kernel module, required for sing-box to create TUN interfaces.
  boot.kernelModules = [ "tun" ];

  # Add sing-box related packages.
  # This includes the core service and the GUI application.
  environment.systemPackages = with pkgs; [
    sing-box
    #gui-for-singbox
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
  networking.firewall.trustedInterfaces = [
    "Sing-Box"
    "podman0"
  ];

  # Enable IP forwarding for TUN interface
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  services.resolved.enable = false;

  networking.networkmanager.dns = "none";
}
