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

            local function register(name, filetypes, markers, provider)
                dap.providers.configs[name] = function(bufnr)
                    if not vim.tbl_contains(filetypes, vim.bo[bufnr].filetype) then
                        return {}
                    end

                    return provider(vim.fs.root(bufnr, markers))
                end
            end

            local function find(cwd)
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

            register("c", { "c" }, { "Makefile" }, function(cwd)
                return {
                    {
                        name = "Launch",
                        type = "gdb",
                        request = "launch",
                        program = find(cwd),
                        args = {},
                        cwd = cwd,
                        stopAtBeginningOfMainSubprogram = false,
                    },
                }
            end)

            register("python", { "python" }, { "pyproject.toml", "setup.py", "setup.cfg" }, function(cwd)
                return {
                    {
                        name = "Launch",
                        type = "debugpy",
                        request = "launch",
                        program = find(cwd),
                        args = {},
                        cwd = cwd,
                    },
                }
            end)

            register("zig", { "zig" }, { "build.zig" }, function(cwd)
                if not cwd then
                    return {}
                end

                local out = vim.fs.joinpath(cwd, "zig-out")

                if vim.fn.isdirectory(out) == 0 then
                    out = cwd
                end

                return {
                    {
                        name = "Launch",
                        type = "gdb",
                        request = "launch",
                        program = find(out),
                        args = {},
                        cwd = cwd,
                        stopAtBeginningOfMainSubprogram = false,
                    },
                }
            end)
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
