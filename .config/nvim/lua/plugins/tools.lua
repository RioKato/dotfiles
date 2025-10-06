return {
    {
        "stevearc/overseer.nvim",

        config = function()
            require("overseer").setup({
                task_list = {
                    direction = "left",
                },

                templates = {
                    "builtin",
                    "python.run",
                    "zig.test",
                    "zig.build",
                    "latex.uplatex",
                    "latex.dvipdfmx",
                },
            })

            vim.keymap.set("n", "r", "<cmd>OverseerRun<cr>")
            vim.keymap.set("n", "R", "<cmd>OverseerToggle<cr>")
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
