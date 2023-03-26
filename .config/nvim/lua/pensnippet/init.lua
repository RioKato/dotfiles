local M = {}

local shell = require("pensnippet.shell")
local command = require("pensnippet.command")
local powershell = require("pensnippet.powershell")

local function insert_by_lang(results, snippet, lang)
	for line in string.gmatch(snippet, "([^\n]*)\n?") do
		if line ~= "" then
			table.insert(results, { lang = lang, snippet = line })
		end
	end
end

function M.insert(results)
	insert_by_lang(results, shell_snippet, "sh")
	insert_by_lang(results, powershell_snippet, "ps")
	insert_by_lang(results, command_snippet, "cmd")
end

return M
