local opt = vim.opt

-- General settings
opt.mouse = 'a'
opt.autoread = true
opt.updatetime = 1000
opt.autoindent = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.showcmd = true
opt.wrap = true
opt.wildmenu = true
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.encoding = 'utf-8'
opt.fileencoding = 'utf-8'
opt.backspace = 'indent,eol,start'
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.foldenable = false
opt.belloff = 'all'
opt.ttimeoutlen = 10
opt.signcolumn = 'yes'

-- Syntax highlighting
vim.cmd('syntax on')
vim.cmd('filetype indent plugin on')

-- Terminal cursor shape
vim.cmd([[
if empty($TMUX)
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
  let &t_SR = "\<Esc>]50;CursorShape=2\x7"
else
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[1 q"
  let &t_SR = "\e[4 q"
endif
]])

-- Set backup and undo
opt.backup = true
opt.backupcopy = 'auto'
opt.undofile = true
opt.undolevels = 5140

-- Use Neovim's standard data directory instead of custom paths
local backup_dir = vim.fn.stdpath('data') .. '/backup'
local undo_dir = vim.fn.stdpath('data') .. '/undo'

-- Create directories if they don't exist
local function ensure_dir(dir)
    local ok = vim.fn.isdirectory(dir)
    if ok == 0 then
        vim.fn.mkdir(dir, 'p')
    end
end

ensure_dir(backup_dir)
ensure_dir(undo_dir)

opt.backupdir = backup_dir .. '//'
opt.undodir = undo_dir .. '//'

-- Backup and undo file cleanup functions
vim.cmd([[
function! BackupClean(days)
    if isdirectory(&backupdir)
        for file in globpath(&backupdir,"*", 1, 1)
            if localtime() > getftime(file) + 86400 * a:days && delete(file) != 0
                    echo "BackupCleaner: Error deleting '" . file . "'"
                endif
        endfor
    else
        echo "BackupCleaner: Directory not found"
    endif
endfunction

function! UndoClean(days)
    if isdirectory(&undodir)
        for file in globpath(&undodir, '*', 1, 1)
            if localtime() > getftime(file) + 86400 * a:days && delete(file) != 0
                echo "UndoDirCleaner: Error deleting '" . file . "'"
            endif
        endfor
    else
        echo "UndoDirCleaner: Directory not found"
    endif
endfunction

call UndoClean(120)
call BackupClean(120)
]])

-- Nvim.diagnostic settings

-- Auto commands
vim.cmd([[
autocmd InsertLeave,WinEnter * set cursorline
autocmd InsertEnter,WinLeave * set nocursorline

autocmd FileType javascript,typescript call SetTwoSpaces()
autocmd FileType yaml call SetTwoSpaces()
autocmd FileType json,jsonc call SetTwoSpaces()
autocmd FileType css call SetTwoSpaces()
autocmd FileType html call SetTwoSpaces()
autocmd FileType markdown call SetTwoSpaces()

function! SetTwoSpaces()
    setlocal softtabstop=2
    setlocal shiftwidth=2
endfunction

" Surround for latex
autocmd FileType tex let b:AutoPairs = {"(":")","{":"}","[":"]"}

" Jump to last edit
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
]])

-- Theme/color settings (basic settings only, plugin-specific moved to plugin_config.lua)
opt.termguicolors = true
