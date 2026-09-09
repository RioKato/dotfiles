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
                            vim.fn.expand("~/.local/bin/ida-pro-mcp"),
                        },
                    },
                },
                opts = {
                    default_servers = { "ida" },
                },
            },
        },
    },
}
