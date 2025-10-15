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
        "ray-x/lsp_signature.nvim",

        opts = {
            doc_lines = 0,
            hint_enable = false,
        },
    },
}
