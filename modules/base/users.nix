{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "video"
      "input"
      "smbshare"
    ];
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Security configuration
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
