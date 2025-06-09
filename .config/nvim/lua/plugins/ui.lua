return {
    {
        "sainnhe/sonokai",

        config = function()
            vim.cmd.colorscheme("sonokai")
        end,
    },

    {
        "rcarriga/nvim-notify",

        config = function()
            vim.notify = require("notify")
        end,
    },
}
