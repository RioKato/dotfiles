local tmux = require("tmux")

-- vim.keymap.set("n", "r", function()
--     local breakpoint = string.format("break %s:%d", vim.fn.expand("%:p"), vim.fn.line("."))
--     local command = string.format("rr replay -- -ex %s -ex continue", vim.fn.shellescape(breakpoint))
--
--     vim.cmd("write")
--     tmux.popup("rr", command)
-- end, { buffer = true })
