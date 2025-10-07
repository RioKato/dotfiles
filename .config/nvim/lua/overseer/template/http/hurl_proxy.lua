return {
    name = "hurl -k -x http://localhost:8080",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "hurl" },
            args = { "-k", "-x", "http://localhost:8080", file },
        }
    end,

    condition = {
        filetype = { "http" },
    },
}
