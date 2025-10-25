return {
    name = "hurl --path-as-is -A $UA --very-verbose --no-output",

    builder = function()
        local file = vim.fn.expand("%:p")
        local ua = "Mozilla/5.0 (X11; Linux x86_64; rv:143.0) Gecko/20100101 Firefox/143.0"

        return {
            cmd = { "hurl" },
            args = { "--path-as-is", "-A", ua, "--very-verbose", "--no-output", file },
        }
    end,

    condition = {
        filetype = { "hurl" },
    },
}
