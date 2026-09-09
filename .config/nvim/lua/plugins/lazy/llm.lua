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
                    adapter = "anthropic",
                },
                inline = {
                    adapter = "anthropic",
                },
            },
            mcp = {
                servers = {
                    ida = {
                        cmd = {
                            vim.fn.expand("~/.local/share/uv/python/cpython-3.11.16-linux-x86_64-gnu/bin/python3"),
                            vim.fn.expand("~/.local/share/uv/tools/ida-pro-mcp/lib/python3.11/site-packages/ida_pro_mcp/server.py"),
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
