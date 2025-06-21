# Neovim editor module
# 提供可选的 Node.js 支持配置

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.neovim-custom;
in
{
  options.programs.neovim-custom = {
    enable = lib.mkEnableOption "Enable custom Neovim configuration";
    
    withNodejs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Node.js for coc-nvim support";
    };
    
    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [];
      description = "Extra packages to include with Neovim";
    };
  };
  
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # 基础 Neovim
      neovim
      
      # 基础工具
      ripgrep
      fd
      
      # 条件包含 Node.js
    ] ++ lib.optionals cfg.withNodejs [
      nodejs
      npm
    ] ++ cfg.extraPackages;
    
    # 设置默认编辑器
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    
    # Shell 别名
    programs.bash.shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
    
    programs.zsh.shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
  };
} 