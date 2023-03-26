local M = {}

local shell = require("pensnippet.shell")
local command = require("pensnippet.command")
local powershell = require("pensnippet.powershell")

function M.insert(results)
	for line in string.gmatch(shell_snippet, "([^\n]*)\n?") do
		if line ~= "" then
			table.insert(results, { lang = "sh", snippet = line })
		end
	end

	for line in string.gmatch(powershell_snippet, "([^\n]*)\n?") do
		if line ~= "" then
			table.insert(results, { lang = "ps", snippet = line })
		end
	end

	for line in string.gmatch(command_snippet, "([^\n]*)\n?") do
		if line ~= "" then
			table.insert(results, { lang = "cmd", snippet = line })
		end
	end
end

return M
