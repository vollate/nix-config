-- Set locale
vim.cmd([[
let $LANG = 'en_US.UTF-8'
let $LC_CTYPE="en_US.UTF-8"
let $LC_NUMERIC="en_US.UTF-8"
let $LC_TIME="en_US.UTF-8"
let $LC_COLLATE="en_US.UTF-8"
let $LC_MONETARY="en_US.UTF-8"
let $LC_MESSAGES="en_US.UTF-8"
let $LC_PAPER="en_US.UTF-8"
let $LC_NAME="en_US.UTF-8"
let $LC_ADDRESS="en_US.UTF-8"
let $LC_TELEPHONE="en_US.UTF-8"
let $LC_MEASUREMENT="en_US.UTF-8"
let $LC_IDENTIFICATION="en_US.UTF-8"
]])

-- Setup leader key before loading plugins
vim.g.mapleader = '\\'
vim.g.maplocalleader = '.'

-- Load plugins with lazy.nvim
require('plugins')

-- Load settings before plugins to ensure proper configuration
require('settings')

-- Load key mappings
require('keymaps')

-- Apply global plugin configurations defined in plugin_config.lua
-- This should run after plugins are potentially loaded by lazy.nvim
require('plugin_config').apply_global_vim_g_settings()
