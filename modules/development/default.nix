{ lib, pkgs, ... }:

{
  imports = [
    ./programming.nix
    ./docker.nix
    ./virtualisation.nix
  ];

  # Development tools
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gh
    git-lfs
    
    # Editors and IDEs
    neovim
    vim
    emacs
    
    # Build tools
    cmake
    gnumake
    ninja
    
    # Network tools
    wget
    curl
    nmap
    netcat
    wireshark
    
    # System monitoring
    htop
    btop
    iotop
    nethogs
    
    # Archive tools
    unzip
    zip
    p7zip
    rar
    
    # Text processing
    ripgrep
    fd
    jq
    yq
    
    # File management
    tree
    exa
    bat
    
    # Performance analysis
    perf-tools
    strace
    ltrace
  ];

  # Enable development services
  programs = {
    # Enable git system-wide
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.default = "current";
      };
    };
  };
} 