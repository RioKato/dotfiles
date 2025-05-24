-- For practice
vim.keymap.set({ "", "i", "c" }, "<C-c>", '<cmd>echoerr "Don\'t use C-c"<cr>')

vim.keymap.set({ "", "i" }, "<C-u>", "<esc>")
vim.keymap.set("c", "<C-u>", "<C-c>")
vim.keymap.set("t", "<C-u>", "<C-\\><C-n>")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.inccommand = "split"
vim.opt.jumpoptions = "stack"

vim.api.nvim_create_autocmd("VimEnter", {
    command = "clearjumps",
})

vim.api.nvim_create_autocmd("VimEnter", {
    command = "delmarks 0-9A-Za-z^[]",
})

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

local function setup_ime()
    if vim.fn.executable("fcitx5-remote") == 1 then
        vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave", "TermLeave" }, {
            callback = function()
                vim.fn.system({ "fcitx5-remote", "-c" })
            end,
        })
    end
end

local function setup_tab()
    vim.keymap.set("n", "<C-w>t", "<cmd>tabnew %<cr>")
    vim.keymap.set("n", "<C-w>C", "<cmd>tabclose<cr>")
    vim.keymap.set("n", "<C-w>p", "<cmd>tabnext<cr>")
    vim.keymap.set("n", "<C-w>n", "<cmd>tabprevious<cr>")
end

local function setup_quickfix()
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

local function setup_lsp(servers)
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

setup_ime()
setup_tab()
setup_quickfix()
setup_lsp({
    "pyright",
    "ts_ls",
    "cmake",
    "clangd",
    "rust_analyzer",
    "gopls",
    "codeqlls",
    "jdtls",
})

lazy().setup({
    { "folke/lazy.nvim" },

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

    { "windwp/nvim-autopairs", opts = {} },

    { "machakann/vim-sandwich" },

    {
        "Goose97/timber.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },

        opts = {
            log_templates = {
                default = {
                    python = [[print(f"[%filename:%line_number] {%log_target=}")]],
                    c = [[printf("[%filename:%line_number] %log_target=%s\n", %log_target);]],
                },
            },
        },
    },

    { "itchyny/vim-qfedit" },

    { "jghauser/mkdir.nvim" },

    { "williamboman/mason.nvim", opts = {} },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },

        opts = {
            ensure_installed = { "pyright", "ts_ls", "cmake" },
        },
    },

    {
        "saghen/blink.cmp",
        version = "1.*",

        opts = {
            keymap = {
                preset = "default",
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
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
            },
            sources = {
                default = { "lsp", "path", "buffer" },
            },
        },
    },

    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },

        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.formatting.prettier.with({
                        filetypes = { "markdown" },
                    }),
                },
            })
        end,
    },

    {
        "jay-babu/mason-null-ls.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "nvimtools/none-ls.nvim",
        },

        opts = {
            ensure_installed = nil,
            automatic_installation = true,
        },
    },

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
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },

        config = function()
            local actions = require("telescope.actions")

            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-u>"] = false,
                            ["<C-x>"] = actions.nop,
                            ["<C-s>"] = actions.select_horizontal,
                            ["<C-l>"] = actions.send_to_qflist + actions.open_qflist,
                        },
                        n = {
                            ["<C-x>"] = actions.nop,
                            ["<C-s>"] = actions.select_horizontal,
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
                    lsp_definitions = { jump_type = "never" },
                    lsp_references = { jump_type = "never" },
                },
            })

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<space>f", builtin.find_files)
            vim.keymap.set("n", "<space>b", builtin.buffers)
            vim.keymap.set("n", "<space>g", builtin.live_grep)
            vim.keymap.set("n", "<space>G", builtin.current_buffer_fuzzy_find)
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
        "tpope/vim-fugitive",

        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "fugitiveblame", "git" },
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "q", "<cmd>bd<cr>", opts)
                end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    local path = vim.fn.expand("%:p")

                    if path:find("^fugitive://") then
                        vim.keymap.set("n", "q", "<cmd>bd<cr>", opts)
                    end
                end,
            })

            vim.keymap.set("n", "gt", "<cmd>Git blame -w<cr>")
        end,
    },

    {
        "junegunn/gv.vim",
        dependencies = { "tpope/vim-fugitive" },

        config = function()
            vim.keymap.set("n", "gl", "<cmd>GV<cr>")

            vim.keymap.set("n", "gf", function()
                return string.format("<cmd>GV -- %s<cr>", vim.fn.expand("%:p"))
            end, { expr = true })

            vim.keymap.set("n", "gs", function()
                return string.format("<cmd>GV -S %s<cr>", vim.fn.expand("<cword>"))
            end, { expr = true })
        end,
    },

    { "linrongbin16/gitlinker.nvim", opts = {} },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },

        opts = {
            sign = { enabled = false },
        },
    },

    { "HakonHarnes/img-clip.nvim", opts = {} },

    {
        "iamcco/markdown-preview.nvim",
        build = ":call mkdp#util#install()",

        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "r", "<cmd>MarkdownPreview<cr>", opts)
                end,
            })
        end,
    },

    {
        "liuchengxu/graphviz.vim",

        config = function()
            vim.g.graphviz_output_format = "jpg"
            vim.g.graphviz_viewer = "xdg-open"

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dot",
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "r", "<cmd>Graphviz!<cr>", opts)
                end,
            })
        end,
    },

    {
        "voldikss/vim-translator",

        config = function()
            vim.g.translator_default_engines = { "google" }
            vim.g.translator_target_lang = "ja"
            vim.g.translator_window_type = "preview"
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
                    ["<C-v>"] = { "actions.select", opts = { vertical = true } },
                    ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
                    ["<space><space>"] = { "actions.cd", mode = "n" },
                },
            })
            vim.keymap.set("n", "go", function()
                oil.toggle_float(vim.fn.expand("%:h"))
            end)
        end,
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
        "folke/which-key.nvim",
        enabled = true,

        opts = {
            triggers = {
                { "<C-w>" },
                { "z" },
                { "g" },
            },
            plugins = {
                marks = false,
                registers = false,
            },
        },
    },
})
