local root = "plugins.local"

local init = {}

function init.hover()
    require(root .. ".hover").setup()
end

function init:all()
    self.hover()
end

init:all()
