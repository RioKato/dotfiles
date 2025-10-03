return {
    {
        "stevearc/overseer.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },

        config = function()
            require("overseer").setup({
                templates = {
                    "builtin",
                    "zig.test",
                    "zig.build",
                },
            })

            vim.keymap.set("n", "r", "<cmd>OverseerRun<cr>")
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
