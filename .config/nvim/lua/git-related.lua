local M = {}

local function git_blame(path)
	local blame = vim.fn.systemlist({ "git", "blame", "-l", "-s", "--", path })
	if vim.v.shell_error ~= 0 then
		return nil
	end

	local result = {}

	for i, v in ipairs(blame) do
		local hash = string.match(v, "%S+")
		if result[hash] == nil then
			result[hash] = { { from = i, to = i } }
		else
			lines = result[hash]
			if lines[#lines].to + 1 == i then
				lines[#lines].to = i
			else
				lines[#lines + 1] = { from = i, to = i }
			end
		end
	end

	return result
end

local function git_show(hash)
	local show = vim.fn.systemlist({ "git", "show", "--name-only", "--oneline", hash })
	if vim.v.shell_error ~= 0 then
		return nil
	end

	if #show < 2 then
		return nil
	end

	local result = {}

	for i = 2, #show do
		result[#result + 1] = show[i]
	end

	return result
end

local soters = require("telescope.sorters")
local config = require("telescope.config")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

M.list = function(opts)
	local placed = vim.fn.sign_getplaced(vim.fn.bufnr(), { group = "*" })

	if placed[1] == nil or placed[1].signs == nil then
		return nil
	end

	local blame = {}
	for _, v in ipairs(placed[1].signs) do
		if v.name == "GitRelatedSign" then
			blame[v.group] = true
		end
	end

	local sorted = {}
	local cache = {}
	for hash, _ in pairs(blame) do
		local show = git_show(hash)

		for _, path in ipairs(show) do
			if cache[path] == nil then
				cache[path] = git_blame(path)
			end

			if cache[path] and cache[path][hash] then
				for _, pos in ipairs(cache[path][hash]) do
					if sorted[path] == nil then
						sorted[path] = {}
					end

					local temp = sorted[path]
					temp[#temp + 1] = pos
				end
			end
		end
	end

	for path, v in pairs(sorted) do
		table.sort(v, function(x, y)
			return x.from < y.from
		end)

		local merged = nil
		for _, pos in ipairs(v) do
			if merged == nil then
				merged = { pos }
			else
				if merged[#merged].to + 1 == pos.from then
					merged[#merged] = { from = merged[#merged].from, to = pos.to }
				else
					merged[#merged + 1] = pos
				end
			end
		end

		sorted[path] = merged
	end

	local items = {}
	for path, v in pairs(sorted) do
		for _, pos in ipairs(v) do
			local text = string.format("%s:%d", path, pos.from)
			items[#items + 1] = { filename = path, lnum = pos.from, col = 1, text = text }
		end
	end

	opts = opts or {}
	opts.show_line = false
	opts.sorting_strategy = "ascending"

	pickers
		.new(opts, {
			prompt_title = "Git Related",
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
end

vim.fn.sign_define("GitRelatedSign", { linehl = "DiffText" })

M.select = function(path, line1, line2)
	local blame = vim.fn.systemlist({ "git", "blame", "-l", "-s", "--", path })
	if vim.v.shell_error ~= 0 then
		return nil
	end

	for i, v in ipairs(blame) do
		local hash = string.match(v, "%S+")
		blame[i] = hash
	end

	local selected = {}
	if line2 then
		for i = line1, line2 do
			selected[blame[i]] = true
		end
	else
		selected[blame[line1]] = true
	end

	local bufnr = vim.fn.bufnr()

	for hash, _ in pairs(selected) do
		local placed = vim.fn.sign_getplaced(bufnr, { group = hash })

		if placed[1] and #placed[1].signs == 0 then
			for i, v in ipairs(blame) do
				if v == hash then
					vim.fn.sign_place(0, hash, "GitRelatedSign", bufnr, { lnum = i })
				end
			end
		else
			vim.fn.sign_unplace(hash, { buffer = bufnr })
		end
	end
end

M.clear = function()
	local placed = vim.fn.sign_getplaced(vim.fn.bufnr(), { group = "*" })

	if placed[1] == nil or placed[1].signs == nil then
		return nil
	end

	local unplaced = {}
	for _, v in ipairs(placed[1].signs) do
		if v.name == "GitRelatedSign" then
			if not unplaced[v.group] then
				vim.fn.sign_unplace(v.group)
				unplaced[v.group] = true
			end
		end
	end
end

vim.api.nvim_create_user_command("GitRelated", M.list, {})

vim.api.nvim_create_user_command("GitRelatedSelect", function(opts)
	M.select(vim.fn.expand("%:p"), opts.line1, opts.line2)
end, { range = true })

vim.api.nvim_create_user_command("GitRelatedClear", M.clear, {})

return M
