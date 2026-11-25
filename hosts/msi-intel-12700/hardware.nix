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
  # Desktop firmware ships no DPTF tables, so thermald's adaptive mode exits at boot.
  services.thermald.enable = false;

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

  # Keep Intel as the primary GPU; use the RTX 3070 Ti on demand.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Ampere supports the current stable driver and NVIDIA's open kernel module.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
    modesetting.enable = true;
    # The Intel iGPU owns the console, so the headless card needs no fbdev.
    moduleParams.nvidia-drm.fbdev = lib.mkForce 0;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
    # KWin otherwise opens the headless NVIDIA card and keeps waking it; PRIME offload still works.
    # The list is ':'-separated, so a by-path name cannot be used here.
    KWIN_DRM_DEVICES = "/dev/dri/intel-igpu";
  };

  # glvnd and the Vulkan loader still load NVIDIA's libraries into KWin, which then open
  # /dev/nvidia0. Scope this to KWin (and its Xwayland) so nvidia-offload clients are unaffected.
  # Raw unit text: systemd.user.services would also pin a minimal PATH for KWin.
  systemd.user.units."plasma-kwin_wayland.service" = {
    overrideStrategy = "asDropin";
    text = ''
      [Service]
      Environment="__EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json"
      Environment="VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json"
    '';
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

    # Stable iGPU node for KWIN_DRM_DEVICES; cardN numbering changes between boots.
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", DEVPATH=="/devices/pci0000:00/0000:00:02.0/drm/card*", SYMLINK+="dri/intel-igpu"
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
