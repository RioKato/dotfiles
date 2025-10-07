return {
    name = "hurl --test -i -k --path-as-is -x http://localhost:8080",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "hurl" },
            args = { "--test", "-i", "-k", "--path-as-is", "-x", "http://localhost:8080", file },
        }
    end,

    condition = {
        filetype = { "http" },
    },
}
