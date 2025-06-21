{ config, lib, pkgs, ... }:

{
  # 安装 neovim 和相关工具
  home.packages = with pkgs; [
    # 使用带 Node.js 的 Neovim (通过 overlay 提供)
    # 这确保了即使没有开发环境模块，coc-nvim 也能正常工作
    neovim-with-nodejs
    
    # 基础工具
    ripgrep # telescope/搜索需要
    fd # 文件查找需要
    
    # 可选的格式化工具 (可以通过 coc 扩展管理)
    # stylua
    # nixfmt
    # black
    # prettier
  ];

  # 管理 ~/.config/nvim 目录
  # 暂时注释掉配置文件复制，避免路径问题
  # xdg.configFile = {
  #   "nvim" = {
  #     source = ./nvim-config;
  #     recursive = true;
  #   };
  # };
  
  # 设置环境变量
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  
  # 添加 shell 别名
  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
} 