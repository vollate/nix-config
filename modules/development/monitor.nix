{
  config,
  pkgs,
  ...
}:

let
  # Add the NVIDIA driver runpath so btop can load NVML for GPU usage and watts.
  # Check videoDrivers as well: hybrid hosts may use Intel as their primary GPU.
  btopPackage = pkgs.btop.override {
    cudaSupport =
      builtins.elem "nvidia" config.services.xserver.videoDrivers
      || config.nixosVollate.graphicsVendor == "nvidia";
  };
  nvtopPackage =
    # Hybrid systems need both the primary GPU and NVIDIA monitoring backends.
    if builtins.elem "nvidia" config.services.xserver.videoDrivers then
      pkgs.nvtopPackages.full
    else if config.nixosVollate.graphicsVendor or null == "amd" then
      pkgs.nvtopPackages.amd
    else if config.nixosVollate.graphicsVendor or null == "nvidia" then
      pkgs.nvtopPackages.nvidia
    else if config.nixosVollate.graphicsVendor or null == "intel" then
      pkgs.nvtopPackages.intel
    else
      pkgs.nvtopPackages.full;
in
{
  security.wrappers.btop = {
    source = "${btopPackage}/bin/btop";
    capabilities = "cap_sys_admin,cap_sys_rawio=eip";
    owner = "root";
    group = "root";
  };
  environment.systemPackages = with pkgs; [
    btopPackage
    nvtopPackage
    iotop
    nethogs
  ];
}
