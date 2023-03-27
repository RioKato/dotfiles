local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
	error("Telescope interface requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local M = {}

local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function M.insert_home_path(opts)
	local find_command = { "find", vim.fn.expand("~") }
	if vim.fn.executable("locate") then
		find_command = { "locate", "-A", vim.fn.expand("~") }
	end

	local attach_mappings = function(prompt_bufnr, map)
		actions.select_default:replace(function()
			actions.close(prompt_bufnr)
			local selection = action_state.get_selected_entry()
			if selection ~= nil then
				vim.api.nvim_put({ selection.value }, "", false, true)
			end
		end)
		return true
	end

	opts["find_command"] = find_command
	opts["path_display"] = { "absolute" }
	opts["wrap_results"] = false
	opts["attach_mappings"] = attach_mappings

	builtin.find_files(opts)
end

return M
