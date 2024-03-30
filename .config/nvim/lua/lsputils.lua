local M = {}

local function is_extref(params, ms)
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

M.symbols = function(opts)
	opts = opts or {}

	vim.lsp.buf.document_symbol({
		on_list = function(symbol)
			local items = vim.tbl_filter(function(item)
				local params = {}
				params.position = { line = item.lnum - 1, character = item.col }
				params.textDocument = vim.lsp.util.make_text_document_params()
				params.context = { includeDeclaration = false }
				return is_extref(params, opts.ms)
			end, symbol.items)

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

local function callgraph(depth, path, ms)
	if depth == 0 then
		return { path }
	end

	local incoming = vim.lsp.buf_request_sync(0, "callHierarchy/incomingCalls", { item = path[#path] }, ms)

	local append = function(dst, src)
		for _, v in ipairs(src) do
			dst[#dst + 1] = v
		end
	end

	local ret = {}
	for _, v in ipairs(incoming) do
		for _, v in ipairs(v.result) do
			local copy = {}
			append(copy, path)
			copy[#copy + 1] = v.from

			append(ret, callgraph(depth - 1, copy, ms))
		end
	end

	if vim.tbl_isempty(ret) then
		return { path }
	end

	return ret
end

M.callgraph = function(depth, opts)
	opts = opts or {}

	local params = vim.lsp.util.make_position_params()
	vim.lsp.buf_request(0, "textDocument/prepareCallHierarchy", params, function(err, result)
		if err then
			return
		end

		if vim.tbl_isempty(result) then
			return
		end

		local items = {}
		for _, v in ipairs(callgraph(depth, result, opts.ms)) do
			local text = {}
			for _, v in ipairs(v) do
				text[#text + 1] = v.name
			end
			text = table.concat(text, " < ")

			items[#items + 1] = {
				filename = vim.uri_to_fname(v[#v].uri),
				text = text,
				lnum = v[#v].range.start.line + 1,
				col = v[#v].range.start.character + 1,
			}
		end

		opts.wrap_results = true
		pickers
			.new(opts, {
				prompt_title = title,
				finder = finders.new_table({
					results = items,
					entry_maker = opts.entry_maker or make_entry.gen_from_quickfix(opts),
				}),
				previewer = config.values.qflist_previewer(opts),
				sorter = config.values.generic_sorter(opts),
				push_cursor_on_edit = true,
				push_tagstack_on_edit = true,
			})
			:find()
	end)
end

return M
