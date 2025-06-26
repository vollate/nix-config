{ config, lib, pkgs, ... }:

{
  # Security configurations
  security = {
    rtkit.enable = true;
    polkit.enable = true;

    # Allow users in wheel group to use sudo without password for system management
    sudo.extraRules = [{
      users = [ "wheel" ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];
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
    pinentryPackage = pkgs.pinentry-curses;
  };

  # AppArmor (optional, can be enabled for additional security)
  # security.apparmor.enable = true;
}
