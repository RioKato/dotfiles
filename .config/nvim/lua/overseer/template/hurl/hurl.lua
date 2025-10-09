return {
    name = "hurl --path-as-is --very-verbose --no-output",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "hurl" },
            args = { "--path-as-is", "--very-verbose", "--no-output", file },
        }
    end,

    condition = {
        filetype = { "hurl" },
    },
}
