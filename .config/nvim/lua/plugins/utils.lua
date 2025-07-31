return {
    {
        "t9md/vim-quickhl",

        config = function()
            vim.keymap.set({ "n", "x" }, "<C-t>", "<plug>(quickhl-manual-this)")
            vim.keymap.set("n", "<leader>m", "<plug>(quickhl-manual-reset)")
        end,
    },

    {
        "unblevable/quick-scope",

        init = function()
            vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
        end,
    },

    {
        "rapan931/lasterisk.nvim",

        config = function()
            local lasterisk = require("lasterisk")

            vim.keymap.set("n", "*", function()
                lasterisk.search()
            end)
        end,
    },

    { "machakann/vim-sandwich" },

    { "itchyny/vim-qfedit" },

    {
        "Goose97/timber.nvim",
        version = "*",
        opts = {},
    },

    { "linrongbin16/gitlinker.nvim", opts = {} },
}
