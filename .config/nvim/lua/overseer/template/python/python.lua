return {
    name = "python",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "python" },
            args = { file },
        }
    end,

    condition = {
        filetype = { "python" },
    },
}
