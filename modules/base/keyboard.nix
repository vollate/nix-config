{
  # CapsLock: tap for Escape, hold for Control.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "overload(control, esc)";
        esc = "capslock";
        rightcontrol = "rightalt";
        rightalt = "rightcontrol";
      };
    };
  };

  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess", GROUP="input", MODE="0660"
  '';
}
