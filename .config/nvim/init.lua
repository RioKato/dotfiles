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

    vim.keymap.set({ "n", "x" }, "j", "gj")
    vim.keymap.set({ "n", "x" }, "k", "gk")
    vim.keymap.set({ "n", "x" }, "gj", "j")
    vim.keymap.set({ "n", "x" }, "gk", "k")
    vim.keymap.set("n", "x", '"_x')
    vim.keymap.set("c", "<C-f>", "<right>")
    vim.keymap.set("c", "<C-b>", "<left>")
    vim.keymap.set("c", "<C-a>", "<home>")
    vim.keymap.set("c", "<C-e>", "<end>")
    vim.keymap.set("n", "<C-w>z", "<cmd>horizontal resize | vertical resize<cr>")
    vim.keymap.set("n", "<C-w>t", "<cmd>tab sbuffer<cr>")
    vim.keymap.set("n", "<C-w>n", "<cmd>tabnext<cr>")
    vim.keymap.set("n", "<C-w>p", "<cmd>tabprevious<cr>")
    vim.keymap.set("n", "<C-w>o", "<nop>")
    vim.keymap.set("n", "<C-w>T", "<nop>")
    vim.keymap.set("n", "gt", "<nop>")
    vim.keymap.set("n", "gT", "<nop>")
    vim.keymap.set("t", "<esc>", "<c-\\><c-n>")

    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
        end,
    })

    vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
            local curnr = vim.fn.tabpagenr()
            local lastnr = vim.fn.tabpagenr("$")
            local winnr = vim.fn.tabpagewinnr(curnr)
            local cwd = vim.fn.getcwd(winnr, curnr)
            local msg = string.format("TAB: %d/%d\nCWD: %s", curnr, lastnr, cwd)
            vim.notify(msg)
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
            for _, hl in ipairs({
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
            }) do
                vim.api.nvim_set_hl(0, hl, {})
            end
        end,
    })
end

local function init_quickfix()
    vim.keymap.set("n", "<C-l>", "<cmd>copen<cr>")
    vim.keymap.set("n", "<C-n>", "<cmd>silent! cnext<cr>")
    vim.keymap.set("n", "<C-p>", "<cmd>silent! cprevious<cr>")

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function(ev)
            local opts = { buffer = ev.buf }
            vim.keymap.set("n", "q", "<cmd>cclose<cr>", opts)
            vim.keymap.set("n", "<C-o>", "<cmd>silent! colder<cr>", opts)
            vim.keymap.set("n", "<C-i>", "<cmd>silent! cnewer<cr>", opts)
            vim.keymap.set("n", "<enter>", "<cmd>.cc<cr>", opts)
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

            local opts = { buffer = ev.buf }
            vim.keymap.set("n", "<C-h>", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader><space>", function()
                vim.lsp.buf.format({ async = true })
            end, opts)
            vim.keymap.set("n", "<leader>d", function()
                vim.diagnostic.enable(not vim.diagnostic.is_enabled())
            end, opts)
        end,
    })

    vim.lsp.enable({
        "pyright",
        "ts_ls",
        "cmake",
        "clangd",
        "rust_analyzer",
        "gopls",
        "jdtls",
        "zls",
        "texlab",
    })
end

local function init_ime()
    if vim.fn.executable("fcitx5-remote") == 1 then
        vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave", "TermLeave" }, {
            callback = function()
                vim.system({ "fcitx5-remote", "-c" })
            end,
        })

        local toggle = false

        vim.api.nvim_create_autocmd("InsertEnter", {
            callback = function()
                if toggle then
                    vim.system({ "fcitx5-remote", "-o" })
                end
            end,
        })

        vim.keymap.set("n", "<leader>j", function()
            toggle = not toggle
            vim.notify(toggle and "IME ON" or "IME OFF")
        end)
    end
end

init_editor()
init_appearance()
init_quickfix()
init_lsp()
init_ime()

local function lazy()
    local path = string.format("%s/lazy/lazy.nvim", vim.fn.stdpath("data"))

    if not vim.loop.fs_stat(path) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            path,
        })
    end

    vim.opt.rtp:prepend(path)
    return require("lazy")
end

lazy().setup({
    { "folke/lazy.nvim" },
    { import = "plugins" },
    { "neovim/nvim-lspconfig" },

    {
        "nvim-treesitter/nvim-treesitter",

        opts = {
            ensure_installed = { "c", "cpp", "python", "rust", "java", "vim" },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },

        config = function()
            require("treesitter-context").setup({
                mode = "topline",
                separator = "·",
            })

            vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
                callback = function()
                    for _, hl in ipairs({ "TreesitterContext", "TreesitterContextSeparator" }) do
                        vim.api.nvim_set_hl(0, hl, { link = "Normal" })
                    end
                end,
            })
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
            sources = {
                default = { "lsp", "path", "buffer" },
            },
        },
    },

    {
        "folke/snacks.nvim",

        opts = {
            explorer = { enabled = true },

            picker = {
                enabled = true,
                win = {
                    input = {
                        keys = {
                            ["<c-l>"] = { "qflist", mode = { "i", "n" } },
                        },
                    },
                },
            },

            notifier = {
                enabled = true,
                timeout = 3000,
            },
        },

        keys = {
            {
                "<leader>g",
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
                desc = "Visual selection or word",
                mode = { "n", "x" },
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
                nowait = true,
                desc = "References",
            },
        },
    },
})
