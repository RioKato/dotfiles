local root = "plugins.local"

local init = {}

function init.hover()
	require(root .. ".hover").setup()
end

function init.wezterm()
	require(root .. ".wezterm").setup()
end

function init:all()
	self.hover()
	self.wezterm()
end

init:all()
