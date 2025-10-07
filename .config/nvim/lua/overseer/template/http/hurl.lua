return {
    name = "hurl -i --path-as-is",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = { "hurl" },
            args = { "-i", "--path-as-is", file },
        }
    end,

    condition = {
        filetype = { "http" },
    },
}
