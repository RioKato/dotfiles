local function exec(cmd)
	return vim.fn.system({ "tmux", unpack(cmd) })
end

local function active()
	return vim.env.TMUX ~= nil
end

local zoom = {}

function zoom.toggle()
	exec({ "resizep", "-Z" })
end

function zoom.on()
	exec({ "if", "-F", "#{==:#{window_zoomed_flag},0}", "resizep -Z" })
end

function zoom.off()
	exec({ "if", "-F", "#{==:#{window_zoomed_flag},1}", "resizep -Z" })
end

local M = {
	active = active,
	zoom = zoom,
}

return M
