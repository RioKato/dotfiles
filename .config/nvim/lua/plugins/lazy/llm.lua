return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            interactions = {
                chat = {
                    -- adapter = "anthropic",
                    adapter = {
                        name = "deepseek",
                        model = "deepseek-v4-pro",
                    },

                    keymaps = {
                        close = {
                            modes = {
                                n = "Q",
                                i = "<Nop>",
                            },
                        },
                    },
                },
                inline = {
                    -- adapter = "anthropic",
                    adapter = {
                        name = "deepseek",
                        model = "deepseek-v4-pro",
                    },
                },
            },
            mcp = {
                servers = {
                    ida = {
                        cmd = {
                            -- vim.fn.expand("~/.local/bin/ida-pro-mcp"),
                            vim.fn.expand("~/.local/bin/idalib-mcp"),
                            "--stdio",
                        },
                    },
                },
                opts = {
                    default_servers = { "ida" },
                    opts = {
                        language = "Japanese",
                    },
                },
            },
        },
    },
}
