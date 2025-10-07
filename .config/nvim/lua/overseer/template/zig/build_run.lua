local function find(file, opts)
    return vim.fs.find(file, { upward = true, type = "file", path = opts.dir })[1]
end

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
            if not find("build.zig", opts) then
                return false, "No build.zig found"
            end
            return true
        end,
    },
}
