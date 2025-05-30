local function init_editor()
    vim.opt.encoding = "utf-8"
    vim.opt.autoindent = true
    vim.opt.expandtab = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.wrap = false
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.shadafile = "NONE"
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
    vim.opt.virtualedit = "block"
    vim.opt.showmatch = true
    vim.opt.matchtime = 1
    vim.opt.number = true
    vim.opt.cursorline = true
    vim.opt.cursorlineopt = "number"
    vim.opt.laststatus = 0
    vim.opt.statusline = "─"
    vim.opt.fillchars = {
        stl = "─",
        stlnc = "─",
        vert = "│",
        eob = " ",
    }
    vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
        callback = function()
            for _, hl in ipairs({ "StatusLine", "StatusLineNC", "VertSplit" }) do
                vim.api.nvim_set_hl(0, hl, { link = "Normal" })
            end
        end,
    })
    vim.opt.showtabline = 2
    vim.opt.termguicolors = true
    vim.opt.syntax = "on"
    vim.opt.clipboard = "unnamedplus"
    vim.opt.mouse = ""
    vim.g.loaded_matchparen = 1
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.keymap.set({ "n", "x" }, "j", "gj")
    vim.keymap.set({ "n", "x" }, "k", "gk")
    vim.keymap.set({ "n", "x" }, "gj", "j")
    vim.keymap.set({ "n", "x" }, "gk", "k")
    vim.keymap.set({ "n", "x" }, "x", '"_x')
    vim.keymap.set({ "i", "c" }, "<C-d>", "<del>")
    vim.keymap.set("n", "<esc><esc>", "<cmd>nohlsearch<cr>")
    vim.keymap.set("c", "<C-f>", "<right>")
    vim.keymap.set("c", "<C-b>", "<left>")
    vim.keymap.set("c", "<C-a>", "<home>")
    vim.keymap.set("c", "<C-e>", "<end>")
    vim.keymap.set("n", "gt", "<cmd>silent! +tabnext<cr>")
    vim.keymap.set("n", "gT", "<cmd>silent! -tabnext<cr>")
    vim.keymap.set("n", "g^", "<cmd>tabfirst<cr>")
    vim.keymap.set("n", "g$", "<cmd>tablast<cr>")
    vim.keymap.set("n", "gn", "<cmd>tab sbuffer<cr>")
    vim.keymap.set("n", "gx", "<cmd>tabclose<cr>")

    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
        end,
    })
end

local function init_esc(esc)
    vim.keymap.set({ "", "i" }, esc, "<esc>")
    vim.keymap.set("c", esc, "<C-c>")
    vim.keymap.set("t", esc, "<C-\\><C-n>")
end

local function init_ime()
    if vim.fn.executable("fcitx5-remote") == 1 then
        vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave", "TermLeave" }, {
            callback = function()
                vim.fn.system({ "fcitx5-remote", "-c" })
            end,
        })

        vim.keymap.set("n", "gj", function()
            if vim.g.ime_autocmd == nil then
                vim.g.ime_autocmd = vim.api.nvim_create_autocmd("InsertEnter", {
                    callback = function()
                        vim.fn.system({ "fcitx5-remote", "-o" })
                    end,
                })
            else
                vim.api.nvim_del_autocmd(vim.g.ime_autocmd)
                vim.g.ime_autocmd = nil
            end
        end)
    end
end

local function init_tabline()
    function tabline()
        local curnr = vim.fn.tabpagenr()
        local lastnr = vim.fn.tabpagenr("$")
        local tabline = ""
        local lower = 0
        local upper = 0
        local header = "  "
        local hooter = "  "

        if curnr == 1 then
            lower = curnr
            upper = curnr + 2
        elseif curnr == lastnr then
            lower = curnr - 2
            upper = curnr
        else
            lower = curnr - 1
            upper = curnr + 1
        end

        if lower > 1 then
            header = "<="
        end

        if upper < lastnr then
            hooter = "=>"
        end

        for i = 1, lastnr do
            if i == curnr then
                tabline = tabline .. "%#TabLineSel#"
            else
                tabline = tabline .. "%#TabLine#"
            end

            if i >= lower and i <= upper then
                tabline = tabline .. "[%{pathshorten(getcwd())}]"
            end
        end

        tabline = string.format("%s%s%%#TabLineFill#%s%%=(%d/%d)", header, tabline, hooter, curnr, lastnr)
        return tabline
    end

    vim.opt.tabline = "%!v:lua.tabline()"
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

local function init_lsp(servers)
    vim.diagnostic.config({
        signs = false,
        underline = true,
    })

    vim.lsp.config("*", {
        on_attach = function(client, bufnr)
            vim.lsp.completion.enable(true, client.id, bufnr)
        end,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
            local opts = { buffer = ev.buf }
            vim.keymap.set("n", "<C-o>", "<cmd>silent! pop<cr>", opts)
            vim.keymap.set("n", "<C-i>", "<cmd>silent! tag<cr>", opts)
            vim.keymap.set("n", "<C-h>", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<space><space>", function()
                vim.lsp.buf.format({ async = true })
            end, opts)
        end,
    })

    vim.lsp.enable(servers)
end

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

init_editor()
init_esc("<C-u>")
init_ime()
init_tabline()
init_quickfix()
init_lsp({
    "pyright",
    "ts_ls",
    "cmake",
    "clangd",
    "rust_analyzer",
    "gopls",
    "jdtls",
})

lazy().setup({
    { "folke/lazy.nvim" },
    { import = "plugins" },

    {
        "sainnhe/sonokai",

        config = function()
            vim.cmd.colorscheme("sonokai")
        end,
    },

    {
        "folke/zen-mode.nvim",

        config = function()
            require("zen-mode").setup({ window = { width = 0.95 } })
            vim.keymap.set("n", "<C-w>z", "<cmd>ZenMode<cr>")
        end,
    },

    {
        "t9md/vim-quickhl",

        config = function()
            vim.keymap.set({ "n", "x" }, "<C-t>", "<plug>(quickhl-manual-this)")
            vim.keymap.set("n", "gm", "<plug>(quickhl-manual-reset)")
        end,
    },

    {
        "unblevable/quick-scope",

        init = function()
            vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
        end,
    },

    {
        "rapan931/lasterisk.nvim",

        config = function()
            local lasterisk = require("lasterisk")

            vim.keymap.set("n", "*", function()
                lasterisk.search()
            end)
        end,
    },

    { "machakann/vim-sandwich" },

    { "itchyny/vim-qfedit" },

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
                multiline_threshold = 1,
                separator = "━",
            })

            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    vim.api.nvim_set_hl(0, "TreesitterContext", { link = "Normal" })
                    vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "Normal" })
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
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },

        config = function()
            local actions = require("telescope.actions")

            require("telescope").setup({
                defaults = {
                    initial_mode = "normal",
                    mappings = {
                        i = {
                            ["<C-u>"] = false,
                            ["<C-x>"] = actions.nop,
                            ["<C-s>"] = actions.select_horizontal,
                            ["<C-l>"] = actions.send_to_qflist + actions.open_qflist,
                        },
                        n = {
                            ["<C-u>"] = false,
                            ["<C-x>"] = actions.nop,
                            ["<C-s>"] = actions.select_horizontal,
                            ["<C-l>"] = actions.send_to_qflist + actions.open_qflist,
                            ["q"] = actions.close,
                            ["<esc>"] = actions.nop,
                        },
                    },
                    path_display = { "shorten" },
                    layout_config = {
                        width = 0.99,
                        height = 0.99,
                    },
                },
                pickers = {
                    lsp_definitions = {
                        jump_type = "never",
                    },
                    lsp_references = {
                        jump_type = "never",
                    },
                },
            })

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<space>f", builtin.find_files)
            vim.keymap.set("n", "<space>b", builtin.buffers)
            vim.keymap.set("n", "<space>g", builtin.live_grep)
            vim.keymap.set("n", "<space>G", builtin.current_buffer_fuzzy_find)
            vim.keymap.set("n", "<space>t", builtin.tagstack)
            vim.keymap.set("n", "<C-s>", builtin.grep_string)
            vim.keymap.set("n", "``", builtin.marks)

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "<C-j>", builtin.lsp_definitions, opts)
                    vim.keymap.set("n", "<C-k>", builtin.lsp_references, opts)
                    vim.keymap.set("n", "<space>d", builtin.diagnostics, opts)
                end,
            })
        end,
    },

    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },

        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.black.with({
                        extra_args = { "--max-line-length=256" },
                    }),
                    null_ls.builtins.formatting.prettier.with({
                        filetypes = { "markdown" },
                    }),
                },
            })
        end,
    },

    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },

        config = function()
            local oil = require("oil")

            oil.setup({
                default_file_explorer = false,
                view_options = {
                    show_hidden = true,
                },
                keymaps = {
                    ["<C-v>"] = {
                        "actions.select",
                        opts = {
                            vertical = true,
                        },
                    },
                    ["<C-s>"] = {
                        "actions.select",
                        opts = {
                            horizontal = true,
                        },
                    },
                    ["<space><space>"] = {
                        "actions.cd",
                        opts = {
                            scope = "tab",
                        },
                        mode = "n",
                    },
                },
            })

            vim.keymap.set("n", "go", function()
                oil.toggle_float(vim.fn.expand("%:h"))
            end)
        end,
    },

    { "linrongbin16/gitlinker.nvim", opts = {} },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },

        opts = {
            sign = {
                enabled = false,
            },
        },
    },

    {
        "vim-denops/denops.vim",
        enabled = vim.fn.executable("deno") == 1,
    },

    {
        "lambdalisue/kensaku.vim",
        dependencies = { "vim-denops/denops.vim" },
    },

    {
        "lambdalisue/kensaku-search.vim",
        dependencies = { "lambdalisue/kensaku.vim" },

        config = function()
            vim.keymap.set("c", "<cr>", "<plug>(kensaku-search-replace)<cr>")
        end,
    },

    {
        "potamides/pantran.nvim",

        opts = {
            default_engine = "google",
            engines = {
                google = {
                    fallback = {
                        default_source = "en",
                        default_target = "ja",
                    },
                },
            },
            ui = {
                width_percentage = 0.9,
                height_percentage = 0.9,
            },
        },
    },
})
