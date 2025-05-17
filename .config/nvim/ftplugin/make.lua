vim.bo.expandtab = false
local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local directory = vim.fn.expand("%:p:h")
    tmux.popup("make", "make", directory)
end)
