# Host-specific configuration for tb-amd-6800h
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./networking.nix
  ];

  nixosVollate.graphicsVendor = "amd";

  system.stateVersion = "24.11";
}
