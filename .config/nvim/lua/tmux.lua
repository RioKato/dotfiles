local M = {}

M.popup = function(name, command, directory)
    if vim.fn.getenv("TMUX") == nil then
        error("run inside a tmux session")
    end

    directory = directory or vim.fn.expand("%:p:h")

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
        string.format(
            "tmux new -A -s %s -c %s %s \\; set -w remain-on-exit on",
            vim.fn.shellescape(name),
            vim.fn.shellescape(directory),
            vim.fn.shellescape(command)
        ),
    })
end

return M
