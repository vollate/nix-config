-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim
require("lazy").setup({ -- Buffer/Status line
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("plugin_config").setup_bufferline()
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("plugin_config").setup_lualine()
        end
    },
    -- Vim cheatsheet
    "lifepillar/vim-cheat40",
    -- Vimwiki
    {
        "vimwiki/vimwiki",
        init = function()
            require('plugin_config').setup_vimwiki()
        end,
    },
    -- Undo Tree
    "mbbill/undotree",
    -- Markdown
    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end
    },
    "mzlogin/vim-markdown-toc",
    -- File navigation (replacing NERDTree)
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("plugin_config").setup_nvim_tree()
        end
    },
    -- Git
    "rhysd/conflict-marker.vim",
    "tpope/vim-fugitive",
    "mhinz/vim-signify",
    {
        "gisphm/vim-gitignore",
        ft = { "gitignore" }
    },
    -- Auto pairs
    "jiangmiao/auto-pairs",

    -- Rainbow
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufReadPost",
        config = function()
            require("plugin_config").setup_rainbow_delimiters()
        end
    },
    -- Coc
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function()
            require("plugin_config").setup_coc()
        end
    },
    -- Surround
    "tpope/vim-surround",
    -- vimtex
    {
        "lervag/vimtex",
        config = function()
            require("plugin_config").setup_vimtex()
        end
    },
    -- Syntax highlight
    "bfrg/vim-c-cpp-modern",
    -- FZF
    {
        "junegunn/fzf.vim",
        dependencies = { { "junegunn/fzf" } }
    },
    -- Theme
    {
        "sainnhe/sonokai",
        config = function()
            require("plugin_config").setup_colorscheme()
        end
    },
    -- Async
    {
        "skywind3000/asyncrun.vim",
        config = function()
            require("plugin_config").setup_asyncrun()
        end
    },
    {
        "skywind3000/asynctasks.vim",
        config = function()
            require("plugin_config").setup_asynctasks()
        end
    },
    -- EasyMotion
    "easymotion/vim-easymotion",
    -- Tagbar
    {
        "preservim/tagbar",
        config = function()
            require("plugin_config").setup_tagbar()
        end
    },
    -- Comment
    "preservim/nerdcommenter",
    -- Copilot
    "github/copilot.vim",
    -- Buffer
    {
        "mhinz/vim-sayonara",
        cmd = "Sayonara"
    },
    {
        "moll/vim-bbye",
        cmd = "Bbye"
    },
    {
        "djoshea/vim-autoread",
        config = function()
            vim.g.autoread = 1
        end
    },
    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("plugin_config").setup_treesitter()
        end
    },
}, {
    -- Lazy.nvim options
    checker = {
        enabled = true,
        notify = false
    },
    change_detection = {
        notify = false
    },
    ui = {
        border = "rounded"
    }
})
