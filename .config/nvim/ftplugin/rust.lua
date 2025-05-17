local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    tmux.popup("cargo", "cargo run", vim.fn.expand("%:p:h"))
end)
