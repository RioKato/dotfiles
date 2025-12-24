return {
    name = "zig build test",

    builder = function()
        return {
            cmd = { "zig" },
            args = { "build", "test" },
        }
    end,

    condition = {
        filetype = { "zig" },
    },
}
