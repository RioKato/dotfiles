local root = "plugins.local"

local init = {}

function init.hover()
    require(root .. ".hover").setup()
end

function init.wezterm()
    local wezterm = require(root .. ".wezterm")
    wezterm.setup("<C-q>")
end

function init:all()
    self.hover()
    self.wezterm()
end

init:all()
