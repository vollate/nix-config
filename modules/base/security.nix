{
  config,
  lib,
  pkgs,
  ...
}:

let
  pinentryWrapper = pkgs.writeShellScriptBin "pinentry" ''
    if [ -n "''${SSH_CONNECTION:-}" ]; then
      exec ${pkgs.pinentry-curses}/bin/pinentry-curses "$@"
    elif [ -n "''${DISPLAY:-}" ] || [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      exec ${pkgs.pinentry-qt}/bin/pinentry-qt "$@"
    else
      exec ${pkgs.pinentry-curses}/bin/pinentry-curses "$@"
    fi
  '';
in
{
  # Security configurations
  security = {
    rtkit.enable = true;
    polkit.enable = true;

    # Allow users in wheel group to use sudo without password for system management
    sudo.extraRules = [
      {
        users = [ "wheel" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # PAM configuration
  security.pam.services = {
    login.enableGnomeKeyring = true;
    lightdm.enableGnomeKeyring = true;
  };

  # GnuPG configuration
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pinentryWrapper;
  };

  # AppArmor (optional, can be enabled for additional security)
  # security.apparmor.enable = true;
}
