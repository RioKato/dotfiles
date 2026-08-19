return {
    name = "lbug",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = string.format("lbug < %s", vim.fn.shellescape(file)),
        }
    end,

    condition = {
        filetype = { "cypher" },
    },
}
