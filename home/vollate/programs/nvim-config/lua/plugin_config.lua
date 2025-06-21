local M = {}

-- Bufferline config function
function M.setup_bufferline()
    require("bufferline").setup({
        options = {
            numbers = "ordinal", -- Show buffer numbers
            show_buffer_close_icons = true,
            show_close_icon = true,
            separator_style = "slope",
            offsets = { {
                filetype = "NvimTree",
                text = "File Explorer",
                text_align = "center"
            } },

            -- Use coc for diagnostics
            diagnostics = "coc",

            diagnostics_indicator = function(count, level, diagnostics_dict, context)
                local result = ""
                local symbols = { error = "✗ ", warning = "‼ ", info = "ℹ ", hint = "➤ " }
                for kind, n in pairs(diagnostics_dict) do
                    if symbols[kind] and n > 0 then
                        result = result .. symbols[kind] .. n .. " "
                    end
                end
                return result
            end,

            -- Add custom area for diagnostics count on the right
            custom_areas = {
                right = function()
                    local result = {}
                    local seve = vim.diagnostic.severity
                    local error = #vim.diagnostic.get(0, { severity = seve.ERROR })
                    local warning = #vim.diagnostic.get(0, { severity = seve.WARN })
                    local info = #vim.diagnostic.get(0, { severity = seve.INFO })
                    local hint = #vim.diagnostic.get(0, { severity = seve.HINT })

                    if error ~= 0 then
                        table.insert(result, { text = " ✗ " .. error, link = "DiagnosticError" })
                    end

                    if warning ~= 0 then
                        table.insert(result, { text = " ‼ " .. warning, link = "DiagnosticWarn" })
                    end

                    if hint ~= 0 then
                        table.insert(result, { text = " ➤ " .. hint, link = "DiagnosticHint" })
                    end

                    if info ~= 0 then
                        table.insert(result, { text = " ℹ " .. info, link = "DiagnosticInfo" })
                    end
                    return result
                end,
            }



        }
    })
end

-- Lualine config function
function M.setup_lualine()
    require("lualine").setup({
        options = {
            theme = "auto",
            icons_enabled = true,
            section_separators = { left = "", right = "" }, -- slant
            component_separators = { left = "", right = "" }, -- slant thin
            always_divide_middle = true,
        },
        sections = {
            lualine_a = { { "mode", separator = { right = "" }, right_padding = 2 } },
            lualine_b = {
                { "branch", icon = "" },
                "diff",
                "diagnostics",
            },
            lualine_c = {
                { "filename", path = 1 },
            },
            lualine_x = {
                "encoding",
                "fileformat",
                "filetype",
            },
            lualine_y = { "progress" },
            lualine_z = {
                { "location", separator = { left = "" }, left_padding = 2 },
            },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
        },
        tabline = {
            -- Use bufferline's buffers/tabs
        },
        extensions = {
            "nvim-tree", "fzf", "quickfix"
        }
    })
end

-- NvimTree config function
function M.setup_nvim_tree()
    require('nvim-tree').setup {
        sort_by = "case_sensitive",
        view = {
            width = 30
        },
        renderer = {
            group_empty = true,
            icons = {
                show = {
                    git = true,
                    file = true,
                    folder = true,
                    folder_arrow = true
                }
            }
        },
        filters = {
            dotfiles = false
        },
        git = {
            enable = true,
            ignore = true
        },
        update_focused_file = {
            enable = true,
            update_root = false
        }
    }
end

-- Setup for rainbow
function M.setup_rainbow_delimiters()
    local rainbow_delimiters = require("rainbow-delimiters")

    local languages = {
        "rust", "cpp", "c", "python", "json", "yaml", "toml",
        "html", "css", "javascript", "typescript", "go", "markdown", "vim"
    }

    local query_config = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
        python = 'rainbow-blocks',
        bash = 'rainbow-blocks',
    }

    for _, lang in ipairs(languages) do
        query_config[lang] = query_config[lang] or 'rainbow-delimiters'
    end

    vim.g.rainbow_delimiters = {
        strategy = {
            [''] = rainbow_delimiters.strategy['global'],
            vim = rainbow_delimiters.strategy['local'],
        },
        query = query_config,
        highlight = {
            'RainbowDelimiterRed',
            'RainbowDelimiterYellow',
            'RainbowDelimiterBlue',
            'RainbowDelimiterOrange',
            'RainbowDelimiterGreen',
            'RainbowDelimiterViolet',
            'RainbowDelimiterCyan',
        },
    }
end

-- Setup for colorscheme (moved from settings.lua)
function M.setup_colorscheme()
    -- Theme/color settings
    vim.opt.termguicolors = true
    vim.cmd('set t_Co=256')

    vim.g.sonokai_style = 'maia'
    vim.g.sonokai_enable_italic = 1
    vim.g.sonokai_transparent_background = 0
    vim.g.sonokai_diagnostic_text_highlight = 1
    vim.g.sonokai_better_performance = 1

    -- Safe colorscheme function that doesn't error when the scheme isn't available
    local function set_colorscheme(name)
        local status_ok, _ = pcall(vim.cmd, "colorscheme " .. name)
        if not status_ok then
            vim.notify("Colorscheme " .. name .. " not found! Using default.", vim.log.levels.WARN)
            -- Use a default built-in colorscheme as fallback
            pcall(vim.cmd, "colorscheme desert")
            return false
        end
        return true
    end

    -- Apply the colorscheme
    set_colorscheme("sonokai")

    vim.cmd([[
    let &t_Cs = "\e[4:3m"
    let &t_Ce = "\e[4:0m"
    ]])
end

-- Setup for asyncrun
function M.setup_asyncrun()
    vim.g.asyncrun_bell = 1
    vim.g.asyncrun_open = math.max(8, math.floor(vim.fn.winheight(0) / 5))
    vim.g.asyncrun_rootmarks = { '.svn', '.git', '.root', '_darcs', 'build.xml' }
end

-- Setup for asynctasks
function M.setup_asynctasks()
    vim.g.asynctasks_term_pos = 'bottom'
    vim.g.asynctasks_term_focus = 0
    vim.g.asynctasks_term_rows = math.max(8, math.floor(vim.fn.winheight(0) / 5))

    -- AsyncTask templates
    vim.g.asynctasks_template = {}
    vim.g.asynctasks_template.cmake = {
        "[project-init]",
        "command=cmake -B build -GNinja",
        "cwd=<root>",
        "",
        "[project-build]",
        "command=cmake --build build",
        "cwd=<root>",
        "errorformat=%. %#--> %f:%l:%c",
        "",
        "[project-run]",
        "command=",
        "cwd=<root>",
        "output=terminal"
    }

    vim.g.asynctasks_template.cargo = {
        "[project-init]",
        "command=cargo update",
        "cwd=<root>",
        "",
        "[project-build]",
        "command=cargo build",
        "cwd=<root>",
        "errorformat=%. %#--> %f:%l:%c",
        "",
        "[project-run]",
        "command=cargo run",
        "cwd=<root>",
        "output=terminal"
    }
end

-- Setup for tagbar
function M.setup_tagbar()
    vim.g.tagbar_width = math.min(100, math.floor(vim.fn.winwidth(0) / 5))
end

-- Setup for vimtex
function M.setup_vimtex()
    vim.g.vimtex_view_general_viewer = 'okular'
    vim.g.vimtex_compiler_method = 'latexmk'
end

-- Setup for coc.nvim
function M.setup_coc()
    -- Add COC custom commands
    vim.cmd([[
    command! -nargs=0 Format :call CocActionAsync('format')
    command! -nargs=? Fold :call CocAction('fold', <f-args>)
    command! -nargs=0 OR :call CocActionAsync('runCommand', 'editor.action.organizeImport')
    ]])
    vim.g.coc_global_extensions = {
        'coc-json',
        'coc-tsserver',
        'coc-pyright',
        'coc-eslint',
        'coc-prettier',
        'coc-clangd',
        'coc-rust-analyzer',
        'coc-kotlin',
        'coc-html',
        'coc-css',
        'coc-markdownlint',
        'coc-go',
        'coc-cmake',
        'coc-lua',
        'coc-toml',
        'coc-yaml',
    }
end

-- Setup for treesitter
function M.setup_treesitter()
    require("nvim-treesitter.configs").setup {
        ensure_installed = {
            "rust", "cpp", "c", "python", "json", "yaml", "toml", "lua", "python", "bash",
            "html", "css", "javascript", "typescript", "go", "markdown", "vim",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = {
            enable = true,
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<CR>",
                node_incremental = "<CR>",
                node_decremental = "<BS>",
                scope_incremental = "<TAB>",
            },
        },
        rainbow = {
            enable = false,
        },
    }
end

-- VimWiki
function M.setup_vimwiki()
    local home = vim.fn.expand("~") 
    local sep = package.config:sub(1, 1) 

    local function join_path(...)
        return table.concat({ ... }, sep)
    end

    vim.g.vimwiki_list = { {
        path = join_path(home, ".vimwiki"),
        path_html = join_path(home, ".vimwiki", "html"),
        html_header = join_path(home, ".vimwiki", "template", "header.tpl"),
        syntax = "markdown",
        ext = ".md",
    } }

    vim.g.vimwiki_global_ext = 0
end

-- Function to apply global vim.g settings (called from init.lua)
function M.apply_global_vim_g_settings()
    -- Markdown Preview
    vim.g.mkdp_theme = 'dark'
    vim.g.mkdp_page_title = '${name}'

    -- Markdown TOC
    vim.g.vmt_list_item_char = "-"

    -- C++ highlighting
    vim.g.cpp_attributes_highlight = 1
    vim.g.cpp_simple_highlight = 1
    vim.g.cpp_function_highlight = 1
    vim.g.cpp_member_highlight = 1

    -- Any other global settings that weren't already moved to specific plugin setup functions
end

return M
