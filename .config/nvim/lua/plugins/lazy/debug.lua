return {
    {
        "mfussenegger/nvim-dap",
        dependencies = { "folke/snacks.nvim" },

        config = function()
            local function cofiles(cwd)
                return coroutine.create(function(co)
                    Snacks.picker.files({
                        cwd = cwd,
                        confirm = function(picker, item)
                            picker:close()
                            coroutine.resume(co, item._path)
                        end,
                    })
                end)
            end

            local dap = require("dap")

            dap.adapters = {
                gdb = {
                    type = "executable",
                    command = "gdb",
                    args = { "--interpreter=dap" },
                },
                debugpy = {
                    type = "executable",
                    command = "debugpy-adapter",
                    options = {
                        source_filetype = "python",
                    },
                },
            }

            dap.configurations = {
                c = {
                    {
                        name = "Launch",
                        type = "gdb",
                        request = "launch",
                        program = function()
                            local cwd = vim.fs.root(0, "Makefile")
                            return cofiles(cwd)
                        end,
                        args = {},
                        cwd = "${workspaceFolder}",
                        stopAtBeginningOfMainSubprogram = false,
                    },
                },
                python = {
                    {
                        name = "Launch",
                        type = "debugpy",
                        request = "launch",
                        program = "${file}",
                    },
                },
                zig = {
                    {
                        name = "Launch",
                        type = "gdb",
                        request = "launch",
                        program = function()
                            local cwd = vim.fs.root(0, "zig-out")

                            if cwd then
                                cwd = vim.fs.joinpath(cwd, "zig-out")
                            end

                            return cofiles(cwd)
                        end,
                        args = {},
                        cwd = "${workspaceFolder}",
                        stopAtBeginningOfMainSubprogram = false,
                    },
                },
            }
        end,

        keys = {
            { "<leader>dd", "<cmd>DapToggleRepl<cr>" },
            { "<leader>db", "<cmd>DapToggleBreakpoint<cr>" },
            { "<leader>dB", "<cmd>DapClearBreakpoints<cr>" },
            { "<leader>dr", "<cmd>DapNew<cr>" },
            { "<leader>dR", "<cmd>DapTerminate<cr>" },
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
