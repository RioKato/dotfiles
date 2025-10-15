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
}
