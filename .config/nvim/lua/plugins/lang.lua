return {
    {
        "vim-denops/denops.vim",
        enabled = vim.fn.executable("deno") == 1,
    },

    {
        "vim-skk/skkeleton",
        dependencies = { "vim-denops/denops.vim" },

        config = function()
            vim.fn["skkeleton#config"]({
                globalDictionaries = {
                    "~/.skk/SKK-JISYO.L",
                },
                markerHenkan = "*",
                markerHenkanSelect = "*",
            })

            vim.keymap.set({ "i", "c", "t" }, "<C-j>", "<plug>(skkeleton-toggle)")
        end,
    },

    {
        "lambdalisue/kensaku.vim",
        dependencies = { "vim-denops/denops.vim" },
    },

    {
        "lambdalisue/kensaku-search.vim",
        dependencies = { "lambdalisue/kensaku.vim" },

        config = function()
            vim.keymap.set("c", "<cr>", "<plug>(kensaku-search-replace)<cr>")
        end,
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
