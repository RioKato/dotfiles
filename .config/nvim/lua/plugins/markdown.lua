return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },

        opts = {
            sign = {
                enabled = false,
            },
        },
    },

    {
        "iamcco/markdown-preview.nvim",
        build = ":call mkdp#util#install()",

        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "r", "<cmd>MarkdownPreview<cr>", opts)
                end,
            })
        end,
    },

    { "HakonHarnes/img-clip.nvim", opts = {} },
}
