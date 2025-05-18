vim.bo.expandtab = false
local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    tmux.popup("make", "make")
end, { buffer = true })
