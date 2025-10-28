local Tmux = {}

function Tmux.exec(cmd)
    return vim.fn.system({ "tmux", unpack(cmd) })
end

function Tmux.enabled()
    return vim.env.TMUX ~= nil
end

local Zoom = {}

function Zoom:toggle()
    Tmux.exec({ "resizep", "-Z" })
end

function Zoom:enabled()
    local flag = Tmux.exec({ "display", "-p", "#{window_zoomed_flag}" })
    return flag:byte(1) == ("1"):byte(1)
end

function Zoom:on()
    if not self:enabled() then
        self:toggle()
    end
end

function Zoom:off()
    if self:enabled() then
        self:toggle()
    end
end

local M = {
    Tmux = Tmux,
    Zoom = Zoom,
}

return M
