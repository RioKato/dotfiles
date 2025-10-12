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
                        return {
                            { string.format("%d. ", item.id) },
                            { item.text, string.format("Overseer%s", item.status) },
                        }
                    end,

                    confirm = function(picker, item)
                        if item == nil then
                            return
                        end

                        picker:close()
                        overseer.run_action(item, "open float")
                    end,
                })
            end

            local keys = {
                { "n", "r", "<cmd>OverseerRun<cr>" },
                { "n", "R", pick },
            }

            for _, key in ipairs(keys) do
                vim.keymap.set(key[1], key[2], key[3])
            end
        end,
    },

    {
        "andythigpen/nvim-coverage",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
}
