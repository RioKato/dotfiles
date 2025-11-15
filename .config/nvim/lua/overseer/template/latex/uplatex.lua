return {
    name = "uplatex",

    builder = function()
        local file = vim.fn.expand("%:t")
        local cwd = vim.fn.expand("%:p:h")

        return {
            cmd = { "docker" },
            args = {
                "run",
                "-it",
                "--rm",
                "-v",
                ("%s:/workdir"):format(cwd),
                "texlive/texlive",
                "uplatex",
                "-interaction=nonstopmode",
                file,
            },
            cwd = cwd,
        }
    end,

    condition = {
        filetype = { "tex" },
    },
}
