{ ... }:

{
  # Swap CapsLock and Escape, remap RightAlt/RightCtrl via udev hwdb
  services.udev.extraHwdb = ''
    # USB keyboard
    evdev:input:b0003*
     KEYBOARD_KEY_70039=esc
     KEYBOARD_KEY_70029=capslock
     KEYBOARD_KEY_700e4=rightalt
     KEYBOARD_KEY_700e6=rightctrl

    # AT/PS2 keyboard
    evdev:input:b0011*
     KEYBOARD_KEY_3a=esc
     KEYBOARD_KEY_01=capslock
     KEYBOARD_KEY_b8=rightctrl

    # Bluetooth keyboard
    evdev:input:b0005*
     KEYBOARD_KEY_70039=esc
     KEYBOARD_KEY_70029=capslock
     KEYBOARD_KEY_700e4=rightalt
     KEYBOARD_KEY_700e6=rightctrl
  '';
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess", GROUP="input", MODE="0660"
  '';
}
