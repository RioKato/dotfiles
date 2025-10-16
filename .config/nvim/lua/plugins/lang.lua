return {
    {
        "vim-denops/denops.vim",
        enabled = vim.fn.executable("deno") == 1,
    },

    {
        "vim-skk/skkeleton",
        dependencies = { "vim-denops/denops.vim" },
        lazy = false,

        config = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "skkeleton-initialize-pre",
                callback = function()
                    vim.fn["skkeleton#config"]({
                        globalDictionaries = {
                            "~/.skk/dict/SKK-JISYO.L",
                        },
                        markerHenkan = "",
                        markerHenkanSelect = "",
                        showCandidatesCount = 0x100,
                    })

                    vim.fn["skkeleton#register_kanatable"]("rom", {
                        ["/"] = { "・", "" },
                        [";"] = { "；", "" },
                        ["<s-l>"] = { "", "" },
                        ["l"] = { "", "" },
                    })
                end,
            })
        end,

        keys = {
            { "<C-j>", "<plug>(skkeleton-toggle)", mode = { "i", "c", "t" }, desc = "skkeleton-toggle" },
        },
    },

    {
        "lambdalisue/kensaku.vim",
        dependencies = { "vim-denops/denops.vim" },
    },

    {
        "lambdalisue/kensaku-search.vim",
        dependencies = { "lambdalisue/kensaku.vim" },

        keys = {
            { "<cr>", "<plug>(kensaku-search-replace)<cr>", mode = { "c" }, desc = "kensaku-search-replace" },
        },
    },

    {
        "potamides/pantran.nvim",

        opts = {
            default_engine = "google",
            engines = {
                google = {
                    fallback = {
                        default_source = "en",
                        default_target = "ja",
                    },
                },
            },
            ui = {
                width_percentage = 0.9,
                height_percentage = 0.9,
            },
        },
    },
}
