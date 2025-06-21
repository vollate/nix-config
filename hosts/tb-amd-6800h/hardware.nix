{ config, lib, pkgs, ... }:

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
  
  # Graphics configuration (adjust for your hardware)
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    
    # For AMD graphics
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    
    # For 32-bit support
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
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
  
  # Sound
  sound.enable = false; # Using PipeWire instead
} 