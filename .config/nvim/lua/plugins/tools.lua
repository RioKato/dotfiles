return {
    {
        "stevearc/overseer.nvim",
        dependencies = { "folke/snacks.nvim" },

        config = function()
            local overseer = require("overseer")

            overseer.setup({
                task_list = {
                    direction = "left",
                },

                templates = {
                    "builtin",
                    "python",
                    "zig",
                    "latex",
                    "hurl",
                },
            })

            local function pick()
                Snacks.picker.pick({
                    title = "Tasks",
                    layout = "select",

                    finder = function()
                        local tasks = overseer.list_tasks()
                        local reversed = {}

                        for i = #tasks, 1, -1 do
                            tasks[i].text = string.format("%s %s", tasks[i].status, tasks[i].name)
                            table.insert(reversed, tasks[i])
                        end

                        return reversed
                    end,

                    format = function(item)
                        local hl = string.format("Overseer%s", item.status)

                        return {
                            { string.format("%d. ", item.id), hl },
                            { item.text, hl },
                        }
                    end,

                    confirm = function(picker, item)
                        picker:close()
                        overseer.run_action(item, "open float")
                    end,
                })
            end

            vim.keymap.set("n", "r", "<cmd>OverseerRun<cr>")
            vim.keymap.set("n", "R", pick)
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
