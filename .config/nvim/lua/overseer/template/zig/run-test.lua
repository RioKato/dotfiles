return {
    name = "zig run test",

    builder = function()
        return {
            cmd = { "zig" },
            args = { "run", "test" },
        }
    end,

    condition = {
        filetype = { "zig" },
    },
}
