return {
    name = "zig build run",

    builder = function()
        return {
            cmd = { "zig" },
            args = { "build", "run" },
        }
    end,

    condition = {
        filetype = { "zig" },
    },
}
