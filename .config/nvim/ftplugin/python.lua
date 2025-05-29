local tmux = require("tmux")

vim.keymap.set("n", "r", function()
    local script = vim.fn.expand("%:p")
    local command = string.format("python3 %s", vim.fn.shellescape(script))
    local venv = string.format("%s/bin/activate", vim.fn.getcwd())

    if vim.fn.filereadable(venv) == 1 then
        command = string.format("source %s && %s", vim.fn.shellescape(venv), command)
    end

    vim.cmd("write")
    tmux.popup("python", command)
end, { buffer = true })
