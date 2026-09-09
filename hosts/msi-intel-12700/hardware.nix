{
  config,
  lib,
  pkgs,
  ...
}:

{
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };
  services.thermald.enable = lib.mkDefault true;

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
  };

  environment.systemPackages = with pkgs; [
    libva-utils
    vdpauinfo
  ];

  services.fwupd.enable = true;

  # HDD0: enforce writeback independently of /dev/bcacheN numbering.
  # Cache attachment is stored in bcache metadata; this rule never formats disks.
  # Writeback requires a healthy cache: losing it can lose unflushed HDD0 data.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="bcache[0-9]*", ENV{ID_FS_UUID}=="fe687bf7-13bb-4e2c-bd26-f944efba5291", ATTR{bcache/cache_mode}="writeback"
  '';

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
