local Tmux = {}

function Tmux.exec(cmd)
    vim.fn.system({ "tmux", unpack(cmd) })
end

function Tmux:wincmd(hjkl)
    local map = {
        h = "-L",
        j = "-D",
        k = "-U",
        l = "-R",
    }

    self.exec({ "selectp", map[hjkl] })
end

function Tmux:zoom()
    self.exec({ "resizep", "-Z" })
end

local Navi = {}

function Navi:new(zen)
    local obj = {
        zen = zen,
    }

    setmetatable(obj, { __index = self })
    return obj
end

function Navi:wincmd(hjkl)
    local prev = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(hjkl)

    if vim.env.TMUX and prev == vim.api.nvim_get_current_win() then
        Tmux:wincmd(hjkl)
    end
end

function Navi:zoom()
    if self.zen then
        self.zen()
    end

    Tmux:zoom()
end

local M = {}

function M.setup(opts)
    opts = opts or {}
    local navi = Navi:new(opts.zen)

    local keys = {
        {
            "n",
            "<C-w>h",
            function()
                navi:wincmd("h")
            end,
        },
        {
            "n",
            "<C-w>j",
            function()
                navi:wincmd("j")
            end,
        },
        {
            "n",
            "<C-w>k",
            function()
                navi:wincmd("k")
            end,
        },
        {
            "n",
            "<C-w>l",
            function()
                navi:wincmd("l")
            end,
        },
        {
            "n",
            "<C-w>z",
            function()
                navi:zoom()
            end,
        },
    }

    for _, key in ipairs(keys) do
        vim.keymap.set(key[1], key[2], key[3])
    end
end

return M
