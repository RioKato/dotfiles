return {
    name = "rr replay -s 1234",

    builder = function()
        return {
            cmd = { "rr" },
            args = { "replay", "-s", "1234" },
        }
    end,

    condition = {
        filetype = { "c" },
    },
}
