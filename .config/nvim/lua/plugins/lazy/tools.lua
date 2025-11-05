return {
    {
        "stevearc/conform.nvim",

        opts = {
            formatters_by_ft = {
                python = { "black" },
                markdown = { "prettier" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
        },

        keys = {
            {
                "<leader> ",
                function()
                    require("conform").format()
                end,
                desc = "conform",
            },
        },
    },

    {
        "stevearc/overseer.nvim",
        dependencies = { "folke/snacks.nvim" },

        opts = {
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
        },

        keys = {
            { "r", "<cmd>OverseerRun<cr>", desc = "OverseerRun" },
            {
                "R",
                function()
                    local overseer = require("overseer")

                    Snacks.picker.pick({
                        title = "Tasks",
                        layout = "select",

                        finder = function()
                            return vim.iter(overseer.list_tasks())
                                :rev()
                                :map(function(task)
                                    task.text = string.format("%s %s", task.status, task.name)
                                    return task
                                end)
                                :totable()
                        end,

                        format = function(item)
                            return {
                                { string.format("%d. ", item.id) },
                                { item.text, string.format("Overseer%s", item.status) },
                            }
                        end,

                        confirm = function(picker, item)
                            if item then
                                picker:close()
                                overseer.run_action(item, "open float")
                            end
                        end,
                    })
                end,
                desc = "Overseer Task List",
            },
        },
    },
}
