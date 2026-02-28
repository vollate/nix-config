{
  config,
  pkgs,
  ...
}:

let
  nvtopPackage =
    if config.nixosVollate.graphicsVendor or null == "amd" then
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
    source = "${pkgs.btop}/bin/btop";
    capabilities = "cap_sys_admin,cap_sys_rawio=eip";
    owner = "root";
    group = "root";
  };
  environment.systemPackages = with pkgs; [
    btop
    nvtopPackage
    iotop
    nethogs
  ];
}
