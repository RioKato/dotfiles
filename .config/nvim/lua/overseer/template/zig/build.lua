local function get_build_zig(opts)
    return vim.fs.find("build.zig", { upward = true, type = "file", path = opts.dir })[1]
end

return {
    name = "zig build",

    builder = function()
        return {
            cmd = { "zig" },
            args = { "build" },
        }
    end,

    condition = {
        callback = function(opts)
            if vim.fn.executable("zig") == 0 then
                return false, 'Command "zig" not found'
            end
            if not get_build_zig(opts) then
                return false, "No build.zig found"
            end
            return true
        end,
    },
}
