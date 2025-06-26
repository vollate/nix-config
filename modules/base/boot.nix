{ config, lib, pkgs, ... }:

{
  # Bootloader configuration
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 20;
    };
  };

  # Kernel parameters
  boot.kernelParams = [ "quiet" "splash" ];

  # Enable tmpfs for /tmp
  boot.tmp.useTmpfs = true;
}
