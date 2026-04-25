{
  config,
  lib,
  pkgs,
  ...
}:

{
  # 安装 neovim 和相关工具
  home.packages = with pkgs; [
    # 使用带 Node.js 的 Neovim (通过 overlay 提供)
    # 这确保了即使没有开发环境模块，coc-nvim 也能正常工作
    neovim-with-nodejs

    # 基础工具
    ripgrep # telescope/搜索需要
    fd # 文件查找需要
    tree-sitter # nvim-treesitter (new API) requires the tree-sitter CLI

    # Real vim/vi wrapper binaries (shadow system vim in PATH)
    (writeShellScriptBin "vim" "exec nvim \"$@\"")
    (writeShellScriptBin "vi" "exec nvim \"$@\"")
  ];

  # Manage ~/.config/nvim directory
  xdg.configFile."nvim" = {
    source = ../../../dot-config/.config/nvim;
    recursive = true;
  };

  # Set environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
