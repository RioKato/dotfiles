return {
    name = "zig test",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "zig" },
            args = { "test", "-lc", file },
        }
    end,

    condition = {
        filetype = { "zig" },
    },
}
