return {
    {
        "mfussenegger/nvim-dap",
        dependencies = { "folke/snacks.nvim" },

        config = function()
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
                python = {
                    {
                        name = "Launch",
                        type = "debugpy",
                        request = "launch",
                        program = "${file}",
                    },
                },
            }

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

            dap.providers.configs = {
                c = function(bufnr)
                    if not vim.tbl_contains({ "c" }, vim.bo[bufnr].filetype) then
                        return {}
                    end

                    local cwd = vim.fs.root(bufnr, "Makefile")

                    if not cwd then
                        return {}
                    end

                    return {
                        {
                            name = "Launch",
                            type = "gdb",
                            request = "launch",
                            program = function()
                                return cofiles(cwd)
                            end,
                            args = {},
                            cwd = cwd,
                            stopAtBeginningOfMainSubprogram = false,
                        },
                    }
                end,
                zig = function(bufnr)
                    if not vim.tbl_contains({ "zig" }, vim.bo[bufnr].filetype) then
                        return {}
                    end

                    local cwd = vim.fs.root(bufnr, "build.zig")

                    if not cwd then
                        return {}
                    end

                    local out = vim.fs.joinpath(cwd, "zig-out")

                    if vim.fn.isdirectory(out) == 0 then
                        return {}
                    end

                    return {
                        {
                            name = "Launch",
                            type = "gdb",
                            request = "launch",
                            program = function()
                                return cofiles(out)
                            end,
                            args = {},
                            cwd = cwd,
                            stopAtBeginningOfMainSubprogram = false,
                        },
                    }
                end,
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
