return {
    name = "dvipdfmx",

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
                string.format("%s:/workdir", cwd),
                "texlive/texlive",
                "uplatex",
                file,
            },
            cwd = cwd,
            components = {
                {
                    "dependencies",
                    task_names = { "uplatex" },
                },
                "default",
            },
        }
    end,

    condition = {
        filetype = { "tex" },
    },
}
