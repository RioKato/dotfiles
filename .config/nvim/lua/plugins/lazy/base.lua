return {
    {
        "sainnhe/sonokai",

        config = function()
            vim.cmd.colorscheme("sonokai")
        end,
    },

    {
        "neovim/nvim-lspconfig",

        config = function()
            local lss = {
                "clangd",
                "pyright",
                "ts_ls",
                "zls",
                "rust_analyzer",
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
                "<leader>ls",
                function()
                    Snacks.picker.lsp_symbols({
                        layout = { fullscreen = true },
                    })
                end,
                desc = "LSP Symbols",
            },
            {
                "<leader>lw",
                function()
                    Snacks.picker.lsp_workspace_symbols({
                        layout = { fullscreen = true },
                    })
                end,
                desc = "LSP Workspace Symbols",
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
}
