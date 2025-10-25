return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        lazy = false,
        build = ":TSUpdate",
    },

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
                    local hls = {
                        "TreesitterContext",
                        "TreesitterContextSeparator",
                    }

                    for _, hl in ipairs(hls) do
                        vim.api.nvim_set_hl(0, hl, { link = "Normal" })
                    end
                end,
            })
        end,
    },

    {
        "t9md/vim-quickhl",

        keys = {
            { "<C-t>", "<plug>(quickhl-manual-this)", mode = { "n", "x" }, desc = "quickhl-manual-this" },
            { "<leader>m", "<plug>(quickhl-manual-reset)", desc = "quickhl-manual-reset" },
        },
    },

    {
        "unblevable/quick-scope",

        init = function()
            vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
        end,
    },

    {
        "rapan931/lasterisk.nvim",

        keys = {
            {
                "*",
                function()
                    require("lasterisk").search()
                end,
                desc = "lasterisk",
            },
        },
    },

    { "itchyny/vim-qfedit" },

    { "tpope/vim-repeat" },

    { "machakann/vim-sandwich" },

    {
        "Wansmer/treesj",
        opts = {},
        keys = {
            {
                "cct",
                function()
                    require("treesj").toggle()
                end,
                desc = "treesj toggle",
            },
        },
    },

    {
        "Goose97/timber.nvim",
        version = "*",
        opts = {},
    },

    {
        "johmsalas/text-case.nvim",
        opts = {},

        keys = {
            {
                "ccs",
                function()
                    require("textcase").current_word("to_snake_case")
                end,
                desc = "textcase to_snake_case",
            },
            {
                "ccc",
                function()
                    require("textcase").current_word("to_camel_case")
                end,
                desc = "textcase to_camel_case",
            },
        },
    },

    {
        "skosulor/nibbler",

        opts = {
            display_enabled = false,
        },

        keys = {
            { "ccd", "<cmd>NibblerToDec<cr>", desc = "NibblerToDec" },
            { "cch", "<cmd>NibblerToHex<cr>", desc = "NibblerToHex" },
            { "ccb", "<cmd>NibblerToBin<cr>", desc = "NibblerToBin" },
        },
    },

    {
        "notjedi/nvim-rooter.lua",

        opts = {
            rooter_patterns = {
                ".git",
                "Makefile",
                "pyproject.toml",
                "build.zig",
                "go.mod",
                "package.json",
            },
            manual = true,
            cd_scope = "tabpage",
        },

        keys = {
            {
                "<leader>p",
                function()
                    require("nvim-rooter").rooter_default()
                    local cwd = vim.fn.getcwd()
                    vim.notify(string.format("Change Directory:\n  %s", cwd))
                end,
                desc = "Rooter",
            },
        },
    },

    {
        "folke/which-key.nvim",
        opts = {
            triggers = {
                { "c", mode = { "n" } },
            },
        },
    },
}
