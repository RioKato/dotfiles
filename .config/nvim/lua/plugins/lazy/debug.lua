return {
    {
        "andythigpen/nvim-coverage",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
    {
        "mfussenegger/nvim-dap",
        lazy = false,
        config = function()
            local dap = require("dap")
            local launch = {
                name = "idalsp: Launch with GDB",
                type = "idalsp-gdb",
                request = "launch",
                program = function()
                    local root = vim.fs.root(0, "idalsp.json") or vim.fs.root(vim.fn.getcwd(), "idalsp.json")
                    local default = vim.fn.getcwd() .. "/"
                    if root then
                        local path = root .. "/info/input_path"
                        if vim.fn.filereadable(path) == 1 then
                            default = vim.fn.readfile(path)[1] or default
                        end
                    end
                    return vim.fn.input("Executable: ", default, "file")
                end,
                cwd = vim.fn.getcwd,
                stopAtBeginningOfMainSubprogram = true,
            }
            dap.configurations.ida_c = { launch }
            dap.configurations.ida_asm = { launch }
        end,
    },
}
