local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    vim.cmd("write")
    tmux.popup("cargo", "cargo run")
end, { buffer = true })
