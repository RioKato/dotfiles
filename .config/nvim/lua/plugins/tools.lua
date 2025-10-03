return {
    {
        "stevearc/overseer.nvim",

        config = function()
            require("overseer").setup({
                templates = {
                    "builtin",
                    "zig.unit-test",
                    "zig.run-test",
                },
            })

            vim.keymap.set("n", "r", "<cmd>OverseerRun<cr>")
        end,
    },

    {
        "numToStr/FTerm.nvim",

        config = function()
            local fterm = require("FTerm")

            local w3m = fterm:new({
                cmd = "w3m",
                dimensions = {
                    height = 1,
                    width = 1,
                    x = 0,
                    y = 0,
                },
            })

            vim.keymap.set("n", "<leader>w", function()
                w3m:toggle()
            end)

            local gitui = fterm:new({
                cmd = "gitui",
                dimensions = {
                    height = 1,
                    width = 1,
                    x = 0,
                    y = 0,
                },
            })

            vim.api.nvim_create_user_command("GitUI", function()
                gitui:toggle()
            end, {})
        end,
    },

    {
        "andythigpen/nvim-coverage",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },

    {
        "nvim-orgmode/orgmode",

        opts = {
            org_agenda_files = "~/orgfiles/**/*",
            org_default_notes_file = "~/orgfiles/refile.org",
            mappings = {
                disable_all = true,
            },
        },
    },
}
