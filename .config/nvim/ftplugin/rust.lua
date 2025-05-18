local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    tmux.popup("cargo", "cargo run")
end, { buffer = true })
