return {
    name = "hurl --path-as-is -A $UA --test -k -x http://localhost:8080",

    builder = function()
        local file = vim.fn.expand("%:p")
        local ua = "Mozilla/5.0 (X11; Linux x86_64; rv:143.0) Gecko/20100101 Firefox/143.0"

        return {
            cmd = { "hurl" },
            args = { "--path-as-is", "-A", ua, "--test", "-k", "-x", "http://localhost:8080", file },
        }
    end,

    condition = {
        filetype = { "hurl" },
    },
}
