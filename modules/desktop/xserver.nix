{
  config,
  lib,
  pkgs,
  ...
}:

{

  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];

    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.libinput.enable = true;

  services.printing.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
