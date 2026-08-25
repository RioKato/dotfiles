return {
    name = "cypher-shell",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = string.format("cipher-pipe < %s", vim.fn.shellescape(file)),
        }
    end,

    condition = {
        filetype = { "cypher" },
    },
}
