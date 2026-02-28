{
  config,
  lib,
  pkgs,
  inputs,
  username,
  hostname,
  secrets,
  ...
}:

{
  imports = [
    ./programs
    ./desktop
    ./develop
    ./shell
  ];

  # Home Manager configuration
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.11";

    # User packages
    packages = with pkgs; [
      # CLI tools
      ripgrep
      fd
      eza
      bat
      fzf
      zoxide
      pwgen

      # System
      neofetch
      tree
    ];
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # XDG configuration
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
