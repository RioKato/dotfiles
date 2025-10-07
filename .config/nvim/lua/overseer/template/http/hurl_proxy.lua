return {
    name = "hurl -x http://localhost:8080",

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
