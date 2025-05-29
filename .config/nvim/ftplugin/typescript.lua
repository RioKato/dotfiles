local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    vim.cmd("write")
    tmux.popup("node", "npm start")
end, { buffer = true })
