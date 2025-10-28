local Tmux = {}

function Tmux.exec(cmd)
    vim.fn.system({ "tmux", unpack(cmd) })
end

function Tmux:enabled()
    return vim.env.TMUX ~= nil
end

function Tmux:zoom()
    self.exec({ "resizep", "-Z" })
end

return Tmux
