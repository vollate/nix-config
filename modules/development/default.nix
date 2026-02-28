{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./programming.nix
    ./docker.nix
    ./virtualisation.nix
    ./monitor.nix

  ];

  options.nixosVollate.graphicsVendor = lib.mkOption {
    type = lib.types.nullOr (
      lib.types.enum [
        "amd"
        "nvidia"
        "intel"
      ]
    );
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
