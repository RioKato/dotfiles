local root = "plugins.local"

require(root .. ".hover").setup()
require(root .. ".tmux").setup({
    zen = Snacks.zen,
})
