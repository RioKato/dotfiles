local M = {}

M.popup = function(name, command, directory)
    if vim.fn.getenv("TMUX") == nil then
        error("Not in tmux session")
    end

    directory = vim.fn.expand(directory)

    command = string.format(
        "tmux new -A -s %s -c %s %s \\; set -w remain-on-exit on",
        vim.fn.shellescape(name),
        vim.fn.shellescape(directory),
        vim.fn.shellescape(command)
    )

    return vim.fn.system({
        "tmux",
        "popup",
        "-xC",
        "-yC",
        "-w",
        "99%",
        "-h",
        "99%",
        "-d",
        directory,
        "-E",
        command,
    })
end

return M
