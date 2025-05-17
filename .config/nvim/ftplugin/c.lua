local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local command = string.format("break %s:%d", vim.fn.expand("%:p"), vim.fn.line("."))
    command = string.format("rr replay -- -ex %s -ex continue", vim.fn.shellescape(command))
    tmux.popup("rr", command)
end)
