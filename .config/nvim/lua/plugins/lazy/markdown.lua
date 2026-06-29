return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },

        opts = {
            sign = {
                enabled = false,
            },
        },
    },

    {
        "iamcco/markdown-preview.nvim",
        build = ":call mkdp#util#install()",
    },

    {
        "HakonHarnes/img-clip.nvim",
        opts = {},
    },
}
