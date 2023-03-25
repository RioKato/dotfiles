local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
	error("Telescope interface requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function insert_hosts(results)
	local lines = vim.split(vim.fn.system("getent hosts"), "\n")
	local seen = {}

	for i, line in ipairs(lines) do
		local elems = {}
		for elem in string.gmatch(line, "[^%s]+") do
			table.insert(elems, elem)
		end

		if #elems >= 2 then
			for i = 2, #elems do
				local key = elems[i] .. elems[1]
				if not seen[key] then
					seen[key] = true
					table.insert(results, { keyword = elems[i], ip = elems[1] })
				end
			end
		end
	end
end

local function insert_ifs(results)
	local lines = vim.split(vim.fn.system("ip -o address show"), "\n")

	for i, line in ipairs(lines) do
		local elems = {}
		for elem in string.gmatch(line, "[^%s]+") do
			table.insert(elems, elem)
		end

		if #elems > 4 then
			local ip = string.gsub(elems[4], "/%d+$", "")
			table.insert(results, { keyword = elems[2], ip = ip })
		end
	end
end

local pickers = function(opts)
	local results = {}
	insert_hosts(results)
	insert_ifs(results)

	local entry_maker = function(e)
		local display = string.format("%s: %s", e.keyword, e.ip)
		return {
			ordinal = display,
			display = display,
			value = e.ip,
		}
	end

	local attach_mappings = function(prompt_bufnr, map)
		actions.select_default:replace(function()
			actions.close(prompt_bufnr)
			local selection = action_state.get_selected_entry()
			vim.api.nvim_put({ selection.value }, "", false, true)
		end)
		return true
	end

	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "IP Address",
			finder = finders.new_table({
				results = results,
				entry_maker = entry_maker,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = attach_mappings,
		})
		:find()
end

return require("telescope").register_extension({
	setup = function(ext_config, config) end,
	exports = {
		lookup_ip = pickers,
	},
})