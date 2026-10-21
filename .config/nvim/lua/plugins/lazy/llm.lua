return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            adapters = {
                http = {
                    local_llm = function()
                        return require("codecompanion.adapters").extend("openai_compatible", {
                            env = {
                                url = "LOCAL_LLM_URL",
                                api_key = "LOCAL_LLM_API_KEY",
                            },
                            schema = {
                                model = {
                                    default = "LOCAL_LLM_MODEL",
                                },
                            },
                        })
                    end,
                },
            },
            interactions = {
                chat = {
                    keymaps = {
                        close = {
                            modes = {
                                n = "Q",
                                i = "<Nop>",
                            },
                        },
                    },
                    adapter = {
                        name = "deepseek",
                        model = "deepseek-v4-pro",
                    },
                },
                inline = {
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
                            vim.fn.expand("~/.local/bin/idalib-mcp"),
                            "--stdio",
                        },
                    },
                    idalsp = {
                        cmd = {
                            vim.fn.expand("~/.local/bin/idalsp-mcp"),
                        },
                    },
                },
                opts = {
                    opts = {
                        language = "Japanese",
                    },
                },
            },
            prompt_library = {
                ["IDA Analysis"] = {
                    interaction = "chat",
                    description = "Start a chat with idalsp MCP",
                    mcp_servers = { "idalsp" },
                    prompts = {
                        {
                            role = "system",
                            content = "You are a reverse engineering assistant. Use the idalsp MCP tools to inspect the IDA database.",
                        },
                    },
                },
            },
        },
    },
}
