return {
    {
        "folke/which-key.nvim",

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
}
