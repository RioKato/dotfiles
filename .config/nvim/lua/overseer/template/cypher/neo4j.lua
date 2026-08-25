return {
    name = "cypher-shell",

    builder = function()
        local file = vim.fn.expand("%:p")

        return {
            cmd = string.format("cypher-pipe < %s | jq", vim.fn.shellescape(file)),
        }
    end,

    condition = {
        filetype = { "cypher" },
    },
}
