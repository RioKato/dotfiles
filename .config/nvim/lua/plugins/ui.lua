return {
    {
        "sainnhe/sonokai",

        config = function()
            vim.cmd.colorscheme("sonokai")
        end,
    },

    {
        "stevearc/dressing.nvim",
        opts = {},
    },

    {
        "rcarriga/nvim-notify",

        config = function()
            vim.notify = require("notify")
        end,
    },
}
