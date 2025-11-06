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

            local providers = {
                c = {
                    filetypes = { "c" },
                    markers = { "Makefile" },
                    callback = function(cwd)
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
                    end,
                },
                python = {
                    filetypes = { "python" },
                    markers = { "pyproject.toml", "setup.py", "setup.cfg" },
                    callback = function(cwd, bufnr)
                        local program = nil

                        if cwd then
                            program = find(cwd)
                        else
                            program = vim.api.nvim_buf_get_name(bufnr)
                            cwd = vim.fs.dirname(program)
                        end

                        return {
                            {
                                name = "Launch",
                                type = "debugpy",
                                request = "launch",
                                program = program,
                                args = {},
                                cwd = cwd,
                            },
                        }
                    end,
                },
                zig = {
                    filetypes = { "zig" },
                    markers = { "build.zig" },
                    callback = function(cwd)
                        local out = cwd

                        if cwd then
                            local temp = vim.fs.joinpath(cwd, "zig-out")

                            if vim.uv.fs_stat(temp) then
                                out = temp
                            end
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
                    end,
                },
            }

            vim.iter(providers):each(function(name, provider)
                dap.providers.configs[name] = function(bufnr)
                    if not vim.tbl_contains(provider.filetypes, vim.bo[bufnr].filetype) then
                        return {}
                    end

                    return provider.callback(vim.fs.root(bufnr, provider.markers), bufnr)
                end
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
