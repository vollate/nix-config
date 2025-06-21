{ config, lib, pkgs, inputs, username, hostname, ... }:

{
  imports = [
    ./programs
    ./shell
    ./desktop
  ];

  # Home Manager configuration
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
    
    # User packages
    packages = with pkgs; [
      # CLI tools
      ripgrep
      fd
      eza
      bat
      fzf
      zoxide
      starship
      
      # Media
      spotify
      mpv
      yt-dlp
      
      # Development
      gh
      lazygit
      
      # System
      neofetch
      btop
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