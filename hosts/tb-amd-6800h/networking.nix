{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Host-specific networking configuration
  networking = {
    # Disable wake-on-lan for non-existent interface to prevent boot timeout
    # interfaces.enp3s0.wakeOnLan.enable = true;

    # Firewall configuration moved to main default.nix file

    # Host-specific DNS settings (if different from default)
    # nameservers = [ "8.8.8.8" "1.1.1.1" ];
  };

  # SSH configuration moved to main default.nix file
}
