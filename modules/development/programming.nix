{ config, lib, pkgs, ... }:

{
  # Programming languages and tools
  environment.systemPackages = with pkgs; [
    # Python
    python3
    python3Packages.pip
    python3Packages.virtualenv
    
    # Node.js
    nodejs
    nodePackages.pnpm
    
    # Rust
    rustc
    cargo
    rustfmt
    clippy
    
    # Go
    go
    
    # C/C++
    gcc
    clang
    gdb
    lldb
    
    # Java
    jdk17
    maven
    gradle
    
    # Haskell
    ghc
    cabal-install
    stack
    
    # Nix
    nil # Nix language server
    nixfmt
    nixpkgs-fmt
    
    # Web development
    deno
    bun
    
    # Database tools
    sqlite
    postgresql
    mysql80
    
    # Container tools
    podman
    buildah
    skopeo
    
    # VSCode Server dependencies
    wget
    unzip
  ];

  # Enable programming services
  services = {
    # PostgreSQL
    postgresql = {
      enable = lib.mkDefault false;
      package = pkgs.postgresql_15;
    };
    
    # MySQL
    mysql = {
      enable = lib.mkDefault false;
      package = pkgs.mysql80;
    };
  };

  # VSCode Server configuration
  # 创建必要的符号链接以支持 VSCode Server
  system.activationScripts.vscode-server-setup = {
    text = ''
      # 确保 VSCode Server 能找到必要的库
      mkdir -p /usr/bin
      ln -sf ${pkgs.nodejs}/bin/node /usr/bin/node || true
      ln -sf ${pkgs.bash}/bin/bash /bin/bash || true
    '';
    deps = [];
  };

  # 设置环境变量以支持 VSCode Server
  environment.variables = {
    # 确保 VSCode Server 能找到正确的 Node.js
    VSCODE_SERVER_NODE_PATH = "${pkgs.nodejs}/bin/node";
  };
} 