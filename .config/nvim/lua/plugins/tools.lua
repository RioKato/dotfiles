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
                        zig = "zig test %",
                    },
                },
                behavior = {
                    autosave = true,
                },
                ui = {
                    float = {
                        border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
                        height = 0.95,
                        width = 0.95,
                    },
                },
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "python", "rust", "go", "javascript", "typescript", "zig" },
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "r", "<cmd>Jaq<cr>", opts)
                end,
            })
        end,
    },

    {
        "numToStr/FTerm.nvim",

        config = function()
            local fterm = require("FTerm")

            local w3m = fterm:new({
                cmd = "w3m",
                dimensions = {
                    height = 1,
                    width = 1,
                    x = 0,
                    y = 0,
                },
            })

            vim.keymap.set("n", "<leader>w", function()
                w3m:toggle()
            end)

            local gitui = fterm:new({
                cmd = "gitui",
                dimensions = {
                    height = 1,
                    width = 1,
                    x = 0,
                    y = 0,
                },
            })

            vim.api.nvim_create_user_command("GitUI", function()
                gitui:toggle()
            end, {})
        end,
    },

    {
        "andythigpen/nvim-coverage",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },

    {
        "nvim-orgmode/orgmode",

        opts = {
            org_agenda_files = "~/orgfiles/**/*",
            org_default_notes_file = "~/orgfiles/refile.org",
            mappings = {
                disable_all = true,
            },
        },
    },
}
