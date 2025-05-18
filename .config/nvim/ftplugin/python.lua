local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local script = vim.fn.expand("%:p")
    local command = string.format("python3 %s", vim.fn.shellescape(script))
    tmux.popup("python", command)
end, { buffer = true })
