{ lib, pkgs, config, ... }:

let
  # 根据图形供应商选择合适的 nvtop 版本
  nvtopPackage = if config.nixosVollate.graphicsVendor or null == "amd" then
    pkgs.nvtopPackages.amd
  else if config.nixosVollate.graphicsVendor or null == "nvidia" then
    pkgs.nvtopPackages.nvidia
  else if config.nixosVollate.graphicsVendor or null == "intel" then
    pkgs.nvtopPackages.intel
  else
    pkgs.nvtopPackages.full; # 默认使用完整版本
in {
  imports = [ ./programming.nix ./docker.nix ./virtualisation.nix ];

  # 定义选项
  options.nixosVollate.graphicsVendor = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "amd" "nvidia" "intel" ]);
    default = null;
    description = "Graphics vendor for selecting appropriate nvtop package";
  };

  config = {
    # Development tools
    environment.systemPackages = with pkgs; [
      # Version control
      git
      gh
      git-lfs

      # Editors and IDEs
      neovim
      vim

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
      btop
      nvtopPackage
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
      eza
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
  };
}
