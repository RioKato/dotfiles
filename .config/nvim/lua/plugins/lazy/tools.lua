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
                "debugger",
            },
        },

        keys = {
            { "r", "<cmd>OverseerRun<cr>", desc = "OverseerRun" },
            {
                "R",
                function()
                    local overseer = require("overseer")
                    local tasks = vim.iter(overseer.list_tasks()):rev():totable()

                    vim.ui.select(tasks, {
                        prompt = "Tasks",
                        format_item = function(item)
                            return string.format("%s %s", item.status, item.name)
                        end,
                    }, function(item)
                        if item then
                            overseer.run_action(item, "open float")
                        end
                    end)
                end,
                desc = "Overseer Task List",
            },
        },
    },
}
