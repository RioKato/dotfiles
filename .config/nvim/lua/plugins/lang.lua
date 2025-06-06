return {
    {
        "vim-denops/denops.vim",
        enabled = vim.fn.executable("deno") == 1,
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
