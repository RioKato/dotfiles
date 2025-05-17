local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local command = "npm start"
    local directory = vim.fn.expand("%:p:h")
    tmux.popup("node", command, directory)
end)
