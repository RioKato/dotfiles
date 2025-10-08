return {
    name = "hurl --path-as-is --very-verbose",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "hurl" },
            args = { "--path-as-is", "--very-verbose", file },
        }
    end,

    condition = {
        filetype = { "hurl" },
    },
}
