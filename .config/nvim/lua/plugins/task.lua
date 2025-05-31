return {
    {
        "is0n/jaq-nvim",

        config = function()
            require("jaq-nvim").setup({
                cmds = {
                    external = {
                        python = "[ -e bin/activate ] && source bin/activate; python3 %",
                        rust = "cargo run",
                        go = 'go run "$(dirname $(go env GOMOD))/main.go"',
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

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "python", "rust", "go", "javascript", "typescript" },
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "r", "<cmd>Jaq<cr>", opts)
                end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "Jaq",
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "q", "<cmd>quit<cr>", opts)
                end,
            })
        end,
    },
}
