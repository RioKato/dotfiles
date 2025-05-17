local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local script = vim.fn.expand("%:p")
    local command = strings.format("python3 %s", vim.fn.shellescape(script))
    local directory = vim.fn.exnapd("%:p:h")
    tmux.popup("python", command, directory)
end)
