{
  config,
  lib,
  pkgs,
  ...
}:

{
  # AMD CPU optimizations
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # Thermal management
  services.thermald.enable = lib.mkDefault true;

  # Enable ACPI support
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  # Graphics configuration (updated to hardware.graphics)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    # For AMD graphics - RADV driver is enabled by default
    # amdvlk has been removed since it was deprecated by AMD
  };

  # Enable firmware updates
  services.fwupd.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
}
