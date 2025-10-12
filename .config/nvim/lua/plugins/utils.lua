return {
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },

        config = function()
            require("treesitter-context").setup({
                mode = "topline",
                separator = "·",
            })

            vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
                callback = function()
                    for _, hl in ipairs({ "TreesitterContext", "TreesitterContextSeparator" }) do
                        vim.api.nvim_set_hl(0, hl, { link = "Normal" })
                    end
                end,
            })
        end,
    },

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

    { "nicwest/vim-camelsnek" },

    {
        "skosulor/nibbler",

        opts = {
            display_enabled = false,
        },

        keys = {
            { "ccd", "<cmd>NibblerToDec<cr>", desc = "NibblerToDec" },
            { "cch", "<cmd>NibblerToHex<cr>", desc = "NibblerToHex" },
        },
    },

    { "linrongbin16/gitlinker.nvim", opts = {} },
}
