local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
	error("Telescope interface requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pensnippet = require("pensnippet")

local pensnippet = function(opts)
	local results = {}
	pensnippet.insert(results)

	local entry_maker = function(e)
		local display = string.format("%s: %s", e.lang, e.snippet)
		return {
			ordinal = display,
			display = display,
			value = e.snippet,
		}
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

	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Snippet",
			finder = finders.new_table({
				results = results,
				entry_maker = entry_maker,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = attach_mappings,
		})
		:find()
end

return telescope.register_extension({
	setup = function(ext_config, config) end,
	exports = {
		pensnippet = pensnippet,
	},
})
