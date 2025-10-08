return {
    name = "hurl --path-as-is -v",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "hurl" },
            args = { "--path-as-is", "-v", file },
        }
    end,

    condition = {
        filetype = { "http" },
    },
}
