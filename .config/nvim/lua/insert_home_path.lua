local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
	error("Telescope interface requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local M = {}

local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function insert_home_path_by_mode(mode)
	local find_command = { "find", vim.fn.expand("~") }
	if vim.fn.executable("locate") then
		find_command = { "locate", "-A", vim.fn.expand("~") }
	end

	local attach_mappings = nil
	if mode == "n" then
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection ~= nil then
					vim.api.nvim_put({ selection.value }, "", true, true)
				end
			end)
			return true
		end
	elseif mode == "i" then
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection ~= nil then
					vim.schedule(function()
						vim.cmd([[startinsert]])
						vim.api.nvim_put({ selection.value }, "", true, true)
					end)
				end
			end)
			return true
		end
	else
		error("Argument Error: mode must be n or i")
	end

	local opts = {
		find_command = find_command,
		path_display = { "absolute" },
		wrap_results = false,
		attach_mappings = attach_mappings,
	}

	builtin.find_files(opts)
end

function M.insert_home_path_n()
	insert_home_path_by_mode("n")
end

function M.insert_home_path_i()
	insert_home_path_by_mode("i")
end

return M
