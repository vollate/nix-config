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

  services.sunshine.settings = {
    # Auto capture probes the desktop portal and can block startup waiting for
    # local consent. KMS works unattended with the existing CAP_SYS_ADMIN wrapper.
    capture = "kms";
    # Keep remote access on the Intel display/encoder, independent of NVIDIA offload.
    encoder = "vaapi";
    adapter_name = "/dev/dri/by-path/pci-0000:00:02.0-render";
    # Sunshine uses address_family, not the legacy private module's address option.
    address_family = "both";
  };

  system.stateVersion = "25.11";
}
