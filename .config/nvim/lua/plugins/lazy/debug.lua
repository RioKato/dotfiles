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
                        local root = vim.fs.root(0, "Makefile") or vim.fn.getcwd()
                        root = vim.fs.joinpath(root, "/")
                        return vim.fn.input("Path to executable: ", root, "file")
                    end,
                    args = {},
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                },
            }

            dap.adapters.python = {
                type = "executable",
                command = "debugpy-adapter",
                options = {
                    source_filetype = "python",
                },
            }

            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                },
            }

            dap.adapters.zig = dap.adapters.gdb

            dap.configurations.zig = {
                {
                    name = "Launch",
                    type = "gdb",
                    request = "launch",
                    program = function()
                        local root = vim.fs.root(0, "zig-out")

                        if root then
                            root = vim.fs.joinpath(root, "zig-out")
                        else
                            root = vim.fn.getcwd()
                        end

                        root = vim.fs.joinpath(root, "/")
                        return vim.fn.input("Path to executable: ", root, "file")
                    end,
                    args = {},
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                },
            }
        end,

        keys = {
            { "<leader>dd", "<cmd>DapToggleRepl<cr>" },
            { "<leader>db", "<cmd>DapToggleBreakpoint<cr>" },
            { "<leader>dc", "<cmd>DapContinue<cr>" },
            { "<leader>ds", "<cmd>DapStepInto<cr>" },
            { "<leader>dn", "<cmd>DapStepOver<cr>" },
            { "<leader>df", "<cmd>DapStepOut<cr>" },
        },
    },

    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {},
    },

    {
        "andythigpen/nvim-coverage",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
}
