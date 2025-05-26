return {
    "folke/which-key.nvim",
    enabled = true,

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
}
