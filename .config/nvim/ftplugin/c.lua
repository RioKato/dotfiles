local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local break = string.format("break %s:%d", vim.fn.expand("%:p"), vim.fn.line("."))
    local command = string.format("rr replay -- -ex %s -ex continue", vim.fn.shellescape( break))
    local directory = vim.fn.expand("%:p:h")
    tmux.popup('rr', command, directory)
end)
