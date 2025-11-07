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
                            {
                                name = "Connect to localhost:1234",
                                type = "gdb",
                                request = "attach",
                                program = find(cwd),
                                args = {},
                                cwd = cwd,
                                target = "localhost:1234",
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
                        local program = nil

                        if cwd then
                            local out = vim.fs.joinpath(cwd, "zig-out")

                            if vim.uv.fs_stat(out) then
                                program = find(out)
                            end
                        end

                        if not program then
                            program = find(cwd)
                        end

                        return {
                            {
                                name = "Launch",
                                type = "gdb",
                                request = "launch",
                                program = program,
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

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dap-repl",
                callback = function(ev)
                    local keys = { { "n", "q", "<cmd>DapToggleRepl<cr>" } }

                    vim.iter(keys):each(function(key)
                        vim.keymap.set(key[1], key[2], key[3], { buffer = ev.buf })
                    end)
                end,
            })
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
