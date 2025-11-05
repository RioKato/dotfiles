return {
    {
        "mfussenegger/nvim-dap",

        config = function()
            local dap = require("dap")

            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap" },
            }

            dap.configurations.c = {
                {
                    name = "Launch",
                    type = "gdb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    args = {},
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                },
                {
                    name = "Select and attach to process",
                    type = "gdb",
                    request = "attach",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    pid = function()
                        local name = vim.fn.input("Executable name (filter): ")
                        return require("dap.utils").pick_process({ filter = name })
                    end,
                    cwd = "${workspaceFolder}",
                },
            }
        end,

        keys = {
            { "<leader>dd", "<cmd>DapToggleRepl<cr>" },
            { "<leader>db", "<cmd>DapToggleBreakpoint<cr>" },
            { "<leader>dr", "<cmd>DapNew<cr>" },
            { "<leader>dc", "<cmd>DapContinue<cr>" },
            { "<leader>ds", "<cmd>DapStepInto<cr>" },
            { "<leader>dn", "<cmd>DapStepOut<cr>" },
        },
    },

    {
        "andythigpen/nvim-coverage",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
}
