local root = "plugins.local"

local init = {}

function init.hover()
    require(root .. ".hover").setup()
end

function init.wezterm()
    require(root .. ".wezterm").setup()
end

function init.gdb()
    require(root .. ".gdb").setup()
end

function init:all()
    self.hover()
    self.wezterm()
    self.gdb()
end

init:all()
