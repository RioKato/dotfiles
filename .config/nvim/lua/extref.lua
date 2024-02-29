local M = {}

local function is_extref_symbol(params, ms)
	local references = vim.lsp.buf_request_sync(0, "textDocument/references", params, ms)
	for _, v in ipairs(references) do
		for _, v in ipairs(v.result) do
			if v.uri ~= params.textDocument.uri then
				return true
			end
		end
	end

	return false
end

local soters = require("telescope.sorters")
local config = require("telescope.config")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

M.list_symbols = function(opts)
	opts = opts or {}

	vim.lsp.buf.document_symbol({
		on_list = function(symbol)
			local items = {}

			for _, v in ipairs(symbol.items) do
				local params = {}
				params.position = { line = v.lnum - 1, character = v.col }
				params.textDocument = vim.lsp.util.make_text_document_params()
				params.context = { includeDeclaration = false }

				if is_extref_symbol(params, opts.ms) then
					items[#items + 1] = v
				end
			end

			opts.path_display = { "hidden" }
			pickers
				.new(opts, {
					prompt_title = "External Reference Symbols",
					finder = finders.new_table({
						results = items,
						entry_maker = opts.entry_maker or make_entry.gen_from_lsp_symbols(opts),
					}),
					previewer = config.values.qflist_previewer(opts),
					sorter = config.values.prefilter_sorter({
						tag = "symbol_type",
						sorter = config.values.generic_sorter(opts),
					}),
					push_cursor_on_edit = true,
					push_tagstack_on_edit = true,
				})
				:find()
		end,
	})
end

return M
