return {
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
        "ray-x/lsp_signature.nvim",

        opts = {
            doc_lines = 0,
            hint_enable = false,
        },
    },
}
