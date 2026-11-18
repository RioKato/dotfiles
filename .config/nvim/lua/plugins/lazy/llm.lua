return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "RioKato/nvim-qf-mcp",
        },
        opts = {
            extensions = {
                nvim_qf_mcp = {},
            },
            adapters = {
                http = {
                    local_llm = function()
                        return require("codecompanion.adapters").extend("openai_compatible", {
                            env = {
                                url = "LOCAL_LLM_URL",
                                api_key = "LOCAL_LLM_API_KEY",
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
                    adapter = "deepseek",
                },
                inline = {
                    adapter = "deepseek",
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
                },
                opts = {
                    opts = {
                        language = "Japanese",
                    },
                },
            },
            prompt_library = {
                ["Source Analysis"] = {
                    interaction = "chat",
                    description = "Analyze source code with evidence references",
                    mcp_servers = { "nvim-qf-mcp" },
                    tools = { "run_command" },
                    opts = {
                        approval_mode = "yolo",
                    },
                    prompts = {
                        {
                            role = "system",
                            content = "You are a source-code analysis assistant. Use the evidence tool to present source-code locations supporting your findings. Obtain line numbers from source inspection tools; do not guess them.",
                        },
                    },
                },
            },
        },
    },
}
