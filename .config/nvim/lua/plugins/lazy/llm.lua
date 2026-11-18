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
                            content = [[
You are a source-code analysis assistant.

When reporting findings about source code, call the
`evidence` tool to register the relevant source locations.

Collect all relevant locations into a single call.
Use actual file paths and 1-based line numbers.
Never guess line numbers.

Do not mention the evidence tool in your response
unless necessary.

Respond to the user in Japanese.
You may reason and investigate in English.
Keep source-code identifiers and technical terms unchanged.
]],
                        },
                    },
                },
            },
        },
    },
}
