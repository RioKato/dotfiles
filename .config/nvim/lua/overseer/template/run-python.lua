return {
    name = "Run python",
    builder = function()
        return {
            cmd = { "python3" },
            args = { vim.fn.expand("%") },
        }
    end,
    condition = {
        filetype = { "python" },
    },
}
