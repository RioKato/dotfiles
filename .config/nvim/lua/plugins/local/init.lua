local root = "plugins.local"

require(root .. ".hover").setup()

local Tmux = require(root .. ".tmux")

vim.keymap.set("n", "<C-w>z", function()
    Snacks.zen()
    Tmux:zoom()
end)
