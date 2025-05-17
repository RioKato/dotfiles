local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local command = "cargo run"
    local directory = vim.fn.expand("%:p:h")
    tmux.popup("cargo", command, directory)
end)
