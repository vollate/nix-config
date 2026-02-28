# Host-specific configuration for msi-intel-12700
{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./networking.nix
    ../../private/msi-intel-12700
  ];

  nixosVollate.graphicsVendor = "intel";

  system.stateVersion = "25.11";
}
