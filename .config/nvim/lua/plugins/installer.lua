return {
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
}
