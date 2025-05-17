local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local gomod = vim.fn.system({ "go", "env", "GOMOD" })
    local script = gomod:gsub("go.mod\n$", "main.go")
    local command = string.format("go run %s", vim.fn.shellescape(script))
    tmux.popup("go", command, vim.fn.expand("%:p:h"))
end)
