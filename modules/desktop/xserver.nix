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
    
    # Enable touchpad support (enabled default in most desktopManager)
    libinput.enable = true;
  };

  # Enable CUPS to print documents
  services.printing.enable = true;
  
  # Hardware acceleration
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };
} 