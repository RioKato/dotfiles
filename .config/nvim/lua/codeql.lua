M = {}

local soters = require("telescope.sorters")
local config = require("telescope.config")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

M.run_query = function(db, opts)
	opts = opts or {}

	local items = {}
	local command = { "codeql", "query", "run", "-d", db, vim.api.nvim_buf_get_name(0) }
	local stdout = vim.fn.system(command)
	for filename, lnum, col in string.gmatch(stdout, "file://([^:]+):(%d+):(%d+):%d+:%d+") do
		local item = {}
		item.lnum = tonumber(lnum)
		item.col = tonumber(col)
		item.filename = filename
		item.text = filename
		items[#items + 1] = item
	end

	opts.path_display = { "hidden" }
	pickers
		.new(opts, {
			prompt_title = "CodeQL Results",
			finder = finders.new_table({
				results = items,
				entry_maker = opts.entry_maker or make_entry.gen_from_quickfix(opts),
			}),
			previewer = config.values.qflist_previewer(opts),
			sorter = config.values.prefilter_sorter({
				sorter = config.values.generic_sorter(opts),
			}),
			push_cursor_on_edit = true,
			push_tagstack_on_edit = true,
		})
		:find()
end

return M
