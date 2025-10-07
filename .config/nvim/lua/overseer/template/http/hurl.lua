return {
    name = "hurl",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "hurl" },
            args = { file },
        }
    end,

    condition = {
        filetype = { "http" },
    },
}
