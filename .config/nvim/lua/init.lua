vim.opt.inccommand = "split"
vim.opt.jumpoptions = "stack"

vim.api.nvim_create_autocmd("VimEnter", {
    command = "clearjumps",
})

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

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

local function setup_completion()
    vim.opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }
    local keymaps = {
        ["<Tab>"] = "<C-n>",
        ["<C-h>"] = "<C-h><C-x><C-o>",
    }

    for key, replace in pairs(keymaps) do
        vim.keymap.set("i", key, function()
            return vim.fn.pumvisible() == 0 and key or replace
        end, { expr = true })
    end
end

local function install_lazy()
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
end

setup_quickfix()
setup_completion()
install_lazy()

require("lazy").setup({
    { "folke/lazy.nvim" },

    {
        "sainnhe/sonokai",

        config = function()
            vim.cmd("colorscheme sonokai")
        end,
    },

    {
        "t9md/vim-quickhl",

        config = function()
            vim.keymap.set("n", "<C-t>", "<plug>(quickhl-manual-this)")
            vim.keymap.set("x", "<C-t>", "<plug>(quickhl-manual-this)")
            vim.keymap.set("n", "<space>m", "<plug>(quickhl-manual-reset)")
        end,
    },

    { "deris/vim-shot-f" },

    {
        "windwp/nvim-autopairs",

        config = function()
            require("nvim-autopairs").setup()
        end,
    },

    {
        "Goose97/timber.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },

        config = function()
            require("timber").setup({
                log_templates = {
                    default = {
                        python = [[print(f"[%filename:%line_number] {%log_target=}")]],
                        c = [[printf("[%filename:%line_number] %log_target=%s\n", %log_target);]],
                    },
                },
            })
        end,
    },

    { "itchyny/vim-qfedit" },

    {
        "williamboman/mason.nvim",

        config = function()
            require("mason").setup()
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },

        config = function()
            local ensure = {
                "pyright",
                "ts_ls",
                "cmake",
            }

            local lss = {
                "pyright",
                "ts_ls",
                "cmake",
                "clangd",
                "rust_analyzer",
                "gopls",
                "codeqlls",
                "jdtls",
            }

            require("mason-lspconfig").setup({
                ensure_installed = ensure,
            })

            vim.diagnostic.config({
                virtual_text = false,
                signs = false,
                underline = true,
            })

            for _, name in ipairs(lss) do
                vim.lsp.config(name, {
                    on_attach = function(client, bufnr)
                        vim.lsp.completion.enable(true, client.id, bufnr, {
                            autotrigger = true,
                            convert = function(item)
                                return { abbr = item.label:gsub("%b()", "") }
                            end,
                        })
                    end,
                })
            end

            vim.lsp.enable(lss)
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

        config = function()
            require("mason-null-ls").setup({
                ensure_installed = nil,
                automatic_installation = true,
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",

        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "cpp", "python", "rust", "java", "vim" },
            })
        end,
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
            local builtin = require("telescope.builtin")
            local lsputils = require("lsputils")

            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-l>"] = actions.send_to_qflist + actions.open_qflist,
                        },
                    },
                    path_display = { "shorten" },
                    layout_config = {
                        width = 0.99,
                        height = 0.99,
                    },
                },
            })

            vim.keymap.set("n", "<space>f", builtin.find_files)
            vim.keymap.set("n", "<space>b", builtin.buffers)
            vim.keymap.set("n", "<space>g", builtin.live_grep)
            vim.keymap.set("n", "<space>G", builtin.current_buffer_fuzzy_find)
            vim.keymap.set("n", "<C-s>", builtin.grep_string)

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "<C-j>", builtin.lsp_definitions, opts)
                    vim.keymap.set("n", "<C-k>", builtin.lsp_references, opts)
                    vim.keymap.set("n", "<C-h>", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<space>h", lsputils.symbols, opts)
                    vim.keymap.set("n", "<space>d", builtin.diagnostics, opts)
                    vim.keymap.set("n", "<space><space>", function()
                        vim.lsp.buf.format({ async = true })
                    end, opts)
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

            vim.keymap.set("n", "mt", "<cmd>Git blame -w<cr>")
        end,
    },

    {
        "junegunn/gv.vim",
        dependencies = { "tpope/vim-fugitive" },

        config = function()
            vim.keymap.set("n", "ml", "<cmd>GV<cr>")

            vim.keymap.set("n", "mf", function()
                return string.format("<cmd>GV -- %s<cr>", vim.fn.expand("%:p"))
            end, { expr = true })

            vim.keymap.set("n", "ms", function()
                return string.format("<cmd>GV -S %s<cr>", vim.fn.expand("<cword>"))
            end, { expr = true })
        end,
    },

    {
        "linrongbin16/gitlinker.nvim",

        config = function()
            require("gitlinker").setup()
        end,
    },

    {
        "segeljakt/vim-silicon",

        config = function()
            vim.g.silicon = {
                ["theme"] = "Dracula",
                ["font"] = "Hack",
                ["background"] = "#AAAAFF",
                ["shadow-color"] = "#555555",
                ["line-pad"] = 2,
                ["pad-horiz"] = 80,
                ["pad-vert"] = 100,
                ["shadow-blur-radius"] = 0,
                ["shadow-offset-x"] = 0,
                ["shadow-offset-y"] = 0,
                ["line-number"] = true,
                ["round-corner"] = true,
                ["window-controls"] = true,
                ["to-clipboard"] = true,
                ["output"] = "/tmp/silicon.png",
            }
        end,
    },

    {
        "img-paste-devs/img-paste.vim",

        config = function()
            vim.g.mdip_imgdir = "image"
            vim.g.mdip_imgdir_intext = "image"

            vim.api.nvim_create_user_command("ImagePaste", function()
                vim.fn["mdip#MarkdownClipboardImage"]()
            end, {})

            vim.api.nvim_create_user_command("ImageOpen", function()
                vim.fn.system({ "xdg-open", vim.fn.expand("<cfile>") })
            end, {})

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "gp", "<cmd>ImagePaste<cr>", opts)
                    vim.keymap.set("n", "go", "<cmd>ImageOpen<cr>", opts)
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
            vim.keymap.set("n", "gt", "<plug>TranslateW")
            vim.keymap.set("v", "gt", "<plug>TranslateWV")
        end,
    },

    { "liuchengxu/graphviz.vim" },
})
