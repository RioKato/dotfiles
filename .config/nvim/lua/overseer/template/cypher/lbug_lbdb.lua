return {
    name = "lbug temp.lbdb",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = string.format("lbug temp.lbdb < %s", vim.fn.shellescape(file)),
        }
    end,

    condition = {
        filetype = { "cypher" },
    },
}
