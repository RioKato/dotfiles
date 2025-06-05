return {
    {
        "is0n/jaq-nvim",

        config = function()
            require("jaq-nvim").setup({
                cmds = {
                    external = {
                        python = "python3 %",
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
                        border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
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
        end,
    },

    {
        "akinsho/toggleterm.nvim",
        version = "*",

        config = function()
            require("toggleterm").setup({
                direction = "tab",
            })

            local Terminal = require("toggleterm.terminal").Terminal

            local w3m = Terminal:new({
                cmd = "w3m",
                dir = "~/Downloads",
                close_on_exit = true,
            })

            vim.api.nvim_create_user_command("W3M", function()
                w3m:toggle()
            end, {})
        end,
    },

    {
        "andythigpen/nvim-coverage",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
}
