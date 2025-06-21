{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set wrap
      set ignorecase
      set smartcase
      set incsearch
      set hlsearch
      
      " Enable mouse
      set mouse=a
      
      " Enable clipboard
      set clipboard=unnamedplus
    '';
    
    plugins = with pkgs.vimPlugins; [
      # Appearance
      tokyonight-nvim
      nvim-web-devicons
      lualine-nvim
      
      # File management
      nvim-tree-lua
      telescope-nvim
      
      # LSP and completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      
      # Syntax highlighting
      nvim-treesitter.withAllGrammars
      
      # Git integration
      gitsigns-nvim
      
      # Useful plugins
      comment-nvim
      auto-pairs
      which-key-nvim
    ];
  };
} 