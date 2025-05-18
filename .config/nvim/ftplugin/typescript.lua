local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    tmux.popup("node", "npm start")
end, { buffer = true })
