return {
    { "mason-org/mason.nvim", opts = {} },

    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },

        opts = {
            ensure_installed = {
                "pyright",
                "ts_ls",
                "zls",
                "texlab",
                "stylua",
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
                    null_ls.builtins.formatting.black.with({
                        extra_args = { "--line-length=256" },
                    }),
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
            "mason-org/mason.nvim",
            "nvimtools/none-ls.nvim",
        },

        opts = {
            ensure_installed = nil,
            automatic_installation = true,
        },
    },

    {
        "ray-x/lsp_signature.nvim",

        opts = {
            doc_lines = 0,
            hint_enable = false,
        },
    },
}
