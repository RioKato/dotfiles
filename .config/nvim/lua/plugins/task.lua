return {
    {
        "is0n/jaq-nvim",

        opts = {
            cmds = {
                external = {
                    python = "[ -e bin/activate ] && source bin/activate; python3 %",
                },
            },
            behavior = {
                autosave = true,
            },
            ui = {
                float = {
                    height = 0.9,
                    width = 0.9,
                },
            },
        },
    },
}
