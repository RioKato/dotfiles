local function assign_keys(keys, opts)
    for _, key in ipairs(keys) do
        vim.keymap.set(key[1], key[2], key[3], opts)
    end
end

local function init_editor()
    vim.opt.encoding = "utf-8"
    vim.opt.autoindent = true
    vim.opt.expandtab = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.wrap = false
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undofile = false
    vim.opt.autoread = true
    vim.opt.wildmenu = true
    vim.opt.gdefault = true
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.wrapscan = true
    vim.opt.incsearch = true
    vim.opt.hlsearch = true
    vim.opt.inccommand = "split"
    vim.opt.hidden = true
    vim.opt.jumpoptions = "stack"
    vim.opt.splitright = true
    vim.opt.splitbelow = true
    vim.opt.winminwidth = 0
    vim.opt.winminheight = 0
    vim.opt.virtualedit = "block"
    vim.opt.showmatch = true
    vim.opt.matchtime = 1
    vim.opt.clipboard = "unnamedplus"
    vim.opt.mouse = ""
    vim.opt.timeoutlen = 10000
    vim.g.mapleader = " "
    vim.g.loaded_matchparen = 1
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    local keys = {
        { { "n", "x" }, "j", "gj" },
        { { "n", "x" }, "k", "gk" },
        { { "n", "x" }, "gj", "j" },
        { { "n", "x" }, "gk", "k" },
        { "n", "x", '"_x' },
        { "c", "<C-f>", "<right>" },
        { "c", "<C-b>", "<left>" },
        { "c", "<C-a>", "<home>" },
        { "c", "<C-e>", "<end>" },
        { "n", "<C-w>z", "<cmd>horizontal resize | vertical resize<cr>" },
        { "n", "<C-w>t", "<cmd>tab sbuffer<cr>" },
        { "n", "<C-w>n", "<cmd>tabnext<cr>" },
        { "n", "<C-w>p", "<cmd>tabprevious<cr>" },
        { "n", "<C-w>o", "<nop>" },
        { "n", "<C-w>T", "<nop>" },
        { "n", "gt", "<nop>" },
        { "n", "gT", "<nop>" },
        { "t", "<esc>", "<c-\\><c-n>" },
    }

    assign_keys(keys)

    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
        end,
    })
end

local function init_appearance()
    vim.opt.termguicolors = true
    vim.opt.syntax = "on"
    vim.opt.number = true
    vim.opt.cursorline = true
    vim.opt.cursorlineopt = "number"
    vim.opt.signcolumn = "number"
    vim.opt.laststatus = 3
    vim.opt.statusline = "%= [%{mode()}] %t %="
    vim.opt.showtabline = 0
    vim.opt.winborder = "single"
    vim.opt.fillchars = {
        stl = "─",
        stlnc = "─",
        eob = " ",
    }
    vim.g.qf_disable_statusline = 1

    vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
        callback = function()
            local hls = {
                "Normal",
                "NormalNC",
                "StatusLine",
                "StatusLineNC",
                "TabLine",
                "TabLineFill",
                "StatusLineTerm",
                "StatusLineTermNC",
                "WinSeparator",
                "NormalFloat",
                "FloatBorder",
                "FloatTitle",
                "FloatFooter",
                "Pmenu",
            }

            for _, hl in ipairs(hls) do
                vim.api.nvim_set_hl(0, hl, {})
            end
        end,
    })
end

local function init_quickfix()
    local keys = {
        { "n", "<C-l>", "<cmd>copen<cr>" },
        { "n", "<C-n>", "<cmd>silent! cnext<cr>" },
        { "n", "<C-p>", "<cmd>silent! cprevious<cr>" },
    }

    assign_keys(keys)

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function(ev)
            local keys = {
                { "n", "q", "<cmd>cclose<cr>" },
                { "n", "<C-o>", "<cmd>silent! colder<cr>" },
                { "n", "<C-i>", "<cmd>silent! cnewer<cr>" },
                { "n", "<enter>", "<cmd>.cc<cr>" },
            }

            assign_keys(keys, { buffer = ev.buf })
        end,
    })
end

local function init_lsp()
    vim.diagnostic.config({
        signs = true,
        underline = false,
        virtual_lines = true,
        update_in_insert = true,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
            vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)

            local function diagnostic()
                vim.diagnostic.enable(not vim.diagnostic.is_enabled())
            end

            local keys = {
                { "n", "<C-h>", vim.lsp.buf.hover },
                { "n", "<leader>ld", diagnostic },
                { "n", "<leader>lr", vim.lsp.buf.rename },
                { "n", "<leader>lc", vim.lsp.buf.code_action },
            }

            assign_keys(keys, { buffer = ev.buf })
        end,
    })
end

init_editor()
init_appearance()
init_quickfix()
init_lsp()

vim.pack.add({
    "https://github.com/folke/lazy.nvim",
})

require("lazy").setup({
    { import = "plugins" },

    {
        "neovim/nvim-lspconfig",

        config = function()
            local lss = {
                "clangd",
                "pyright",
                "ts_ls",
                "zls",
                "stylua",
            }

            vim.lsp.enable(lss)
        end,
    },

    {
        "saghen/blink.cmp",
        version = "1.*",

        opts = {
            keymap = {
                preset = "none",
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
                ["<C-n>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback" },
                ["<C-g>"] = { "accept" },
            },
            completion = {
                list = {
                    selection = {
                        preselect = false,
                        auto_insert = true,
                    },
                },
                accept = {
                    auto_brackets = {
                        enabled = false,
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                },
            },
            cmdline = {
                keymap = {
                    preset = "inherit",
                    ["<Tab>"] = { "select_next", "fallback" },
                    ["<S-Tab>"] = { "select_prev", "fallback" },
                    ["<C-n>"] = { "select_next", "fallback" },
                    ["<C-p>"] = { "select_prev", "fallback" },
                    ["<C-g>"] = { "accept" },
                },
                completion = {
                    list = {
                        selection = {
                            preselect = false,
                            auto_insert = true,
                        },
                    },
                    menu = {
                        auto_show = true,
                    },
                },
            },
            signature = {
                enabled = true,
                window = {
                    show_documentation = false,
                },
            },
            sources = {
                default = { "lsp", "path", "buffer" },
            },
        },
    },

    {
        "folke/snacks.nvim",
        lazy = false,

        opts = {
            explorer = {
                enabled = true,
            },
            picker = {
                enabled = true,
                win = {
                    input = {
                        keys = {
                            ["<c-l>"] = { "qflist", mode = { "i", "n" } },
                        },
                    },
                    list = {
                        keys = {
                            ["<c-q>"] = "qflist",
                        },
                    },
                },
            },
            notifier = {
                enabled = true,
                timeout = 3000,
            },
            zen = {
                enabled = true,
            },
        },

        keys = {
            {
                "<leader>s",
                function()
                    Snacks.picker.grep({
                        layout = { fullscreen = true },
                    })
                end,
                desc = "Grep",
            },
            {
                "<C-s>",
                function()
                    Snacks.picker.grep_word({
                        layout = { fullscreen = true },
                    })
                end,
                mode = { "n", "x" },
                desc = "Visual selection or word",
            },
            {
                "<leader>o",
                function()
                    Snacks.explorer()
                end,
                desc = "File Explorer",
            },
            {
                "<C-j>",
                function()
                    Snacks.picker.lsp_definitions({
                        layout = { fullscreen = true },
                    })
                end,
                desc = "Goto Definition",
            },
            {
                "<C-k>",
                function()
                    Snacks.picker.lsp_references({
                        layout = { fullscreen = true },
                    })
                end,
                desc = "References",
            },
            {
                "<C-w>z",
                function()
                    Snacks.zen()
                end,
                desc = "Toggle Zen Mode",
            },
        },
    },
})
