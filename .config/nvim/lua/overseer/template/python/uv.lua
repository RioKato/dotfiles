return {
    name = "uv run",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "uv" },
            args = { "run", file },
        }
    end,

    condition = {
        filetype = { "python" },
    },
}
