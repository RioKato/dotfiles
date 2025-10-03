return {
    name = "zig unit test",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "zig" },
            args = { "test", file },
            components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "default",
            },
        }
    end,

    condition = {
        filetype = { "zig" },
    },
}
