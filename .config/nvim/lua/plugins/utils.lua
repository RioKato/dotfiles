return {
    {
        "folke/which-key.nvim",
        enabled = false,

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

    {
        "windwp/nvim-autopairs",

        opts = {
            disable_filetype = {
                "TelescopePrompt",
                "vim",
            },
        },
    },

    {
        "Goose97/timber.nvim",
        version = "*",
        opts = {},
    },
}
