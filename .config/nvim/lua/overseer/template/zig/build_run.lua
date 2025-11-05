return {
    name = "zig build run",

    builder = function()
        return {
            cmd = { "zig" },
            args = { "build", "run" },
        }
    end,

    condition = {
        callback = function(opts)
            if vim.fn.executable("zig") == 0 then
                return false, 'Command "zig" not found'
            end
            if not vim.fs.root(opts.dir, "build.zig") then
                return false, "No build.zig found"
            end
            return true
        end,
    },
}
