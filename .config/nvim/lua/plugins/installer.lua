return {
    { "mason-org/mason.nvim", opts = {} },

    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },

        opts = {
            ensure_installed = { "pyright", "ts_ls", "cmake" },
        },
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
}
