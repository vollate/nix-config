{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:

{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;

    # Enable firewall by default for security (can be overridden in host config)
    firewall = {
      enable = lib.mkDefault true;
    };
  };
}
