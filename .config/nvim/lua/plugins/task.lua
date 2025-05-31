return {
    {
        "is0n/jaq-nvim",

        config = function()
            require("jaq-nvim").setup({
                cmds = {
                    external = {
                        python = "[ -e bin/activate ] && source bin/activate; python3 %",
                        rust = "cargo run",
                        go = "go run $(dirname $(go env GOMOD))/main.go",
                        javascript = "npm start",
                        typescript = "npm start",
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
            })

            vim.keymap.set("n", "r", "<cmd>Jaq<cr>")
        end,
    },
}
