local Tmux = {}

function Tmux.exec(cmd)
    return vim.fn.system({ "tmux", unpack(cmd) })
end

function Tmux:enabled()
    return vim.env.TMUX ~= nil
end

function Tmux:zoom()
    self.exec({ "resizep", "-Z" })
end

function Tmux:zoomed()
    local zoomed = self.exec({ "display", "-p", "#{window_zoomed_flag}" })
    return zoomed:byte(1) == ("1"):byte(1)
end

return Tmux
