{ config, lib, pkgs, ... }:

{
  # Enable the X11 windowing system
  services.xserver = {
    enable = true;
    
    # Configure keymap
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable touchpad support (moved from xserver.libinput)
  services.libinput.enable = true;

  # Enable CUPS to print documents
  services.printing.enable = true;
  
  # Hardware acceleration (updated to hardware.graphics)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
} 