local Tmux = {}

function Tmux.exec(cmd)
    vim.fn.system({ "tmux", unpack(cmd) })
end

function Tmux:enabled()
    return vim.env.TMUX ~= nil
end

function Tmux:wincmd(cmd)
    local map = {
        h = { "selectp", "-L" },
        j = { "selectp", "-D" },
        k = { "selectp", "-U" },
        l = { "selectp", "-R" },
        z = { "resizep", "-Z" },
    }

    self.exec(map[cmd])
end

local Navi = {}

function Navi:new(zen)
    local obj = {
        zen = zen,
    }

    setmetatable(obj, { __index = self })
    return obj
end

function Navi:wincmd(cmd)
    if vim.tbl_contains({ "h", "j", "k", "l" }, cmd) then
        local prev = vim.api.nvim_get_current_win()
        vim.cmd.wincmd(cmd)

        if prev == vim.api.nvim_get_current_win() then
            if Tmux:enabled() then
                Tmux:wincmd(cmd)
            end
        end

        return
    end

    if cmd == "z" then
        if self.zen then
            self.zen()
        end

        if Tmux:enabled() then
            Tmux:wincmd(cmd)
        end

        return
    end
end

local M = {}

function M.setup(opts)
    opts = opts or {}
    local navi = Navi:new(opts.zen)

    for _, cmd in ipairs({ "h", "j", "k", "l", "z" }) do
        vim.keymap.set("n", string.format("<C-w>%s", cmd), function()
            navi:wincmd(cmd)
        end)
    end
end

return M
