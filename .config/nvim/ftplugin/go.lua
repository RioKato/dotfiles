local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local script = vim.fn.system({ "go", "env", "GOMOD" }) .. "/main.go"
    local command = string.format("go run %s", vim.fn.shellescape(script))
    local directory = vim.fn.expand("%:p:h")
    tmux.popup("go", command, directory)
end)
