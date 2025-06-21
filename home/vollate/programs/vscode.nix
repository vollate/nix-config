{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    
    # VSCode 配置文件
    profiles.default = {
      # VSCode 扩展
      extensions = with pkgs.vscode-extensions; [
        # 语言支持
        ms-python.python
        rust-lang.rust-analyzer
        ms-vscode.cpptools
        bradlc.vscode-tailwindcss
        
        # Nix 支持
        jnoortheen.nix-ide
        
        # 主题和图标
        catppuccin.catppuccin-vsc
        pkief.material-icon-theme
        
        # 实用工具
        eamodio.gitlens
        esbenp.prettier-vscode
        # ms-vscode.hexdump  # 该扩展在 nixpkgs 中不可用
        formulahendry.auto-rename-tag
        
        # 远程开发
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-containers
      ];
      
      # VSCode 用户设置
      userSettings = {
        # 外观设置
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "material-icon-theme";
        
        # 编辑器设置
        "editor.fontFamily" = "'JetBrains Mono', 'Fira Code', monospace";
        "editor.fontSize" = 14;
        "editor.fontLigatures" = true;
        "editor.tabSize" = 2;
        "editor.insertSpaces" = true;
        "editor.rulers" = [ 80 120 ];
        "editor.wordWrap" = "on";
        "editor.minimap.enabled" = false;
        
        # 文件设置
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        
        # Git 设置
        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;
        "git.autofetch" = true;
        
        # 终端设置
        "terminal.integrated.fontSize" = 13;
        "terminal.integrated.fontFamily" = "'JetBrains Mono', monospace";
        
        # Python 设置
        "python.defaultInterpreterPath" = "python3";
        "python.linting.enabled" = true;
        "python.linting.pylintEnabled" = false;
        "python.linting.flake8Enabled" = true;
        
        # 远程开发设置
        "remote.SSH.remotePlatform" = {
          "localhost" = "linux";
        };
        
        # Nix 设置
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        
        # 其他设置
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "workbench.startupEditor" = "none";
      };
    };
  };

  # VSCode Server 通过 nixos-vscode-server 模块自动处理
} 