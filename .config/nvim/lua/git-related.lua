local M = {}

local function git_blame(path, from, to)
	local result = {}
	local command = nil

	if from then
		local range = nil

		if to then
			range = string.format("%d,%d", from, to)
		else
			range = string.format("%d", from)
		end

		command = { "git", "blame", "-l", "-s", "-L", range, "--", path }
	else
		command = { "git", "blame", "-l", "-s", "--", path }
	end

	local blame = vim.fn.systemlist(command)
	if vim.v.shell_error ~= 0 then
		return nil
	end

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
	local result = {}
	local show = vim.fn.systemlist({ "git", "show", "--name-only", "--oneline", hash })
	if vim.v.shell_error ~= 0 then
		return nil
	end

	local description = nil
	local path = {}
	for i, v in ipairs(show) do
		if i == 1 then
			description = v
		else
			path[#path + 1] = v
		end
	end

	result.description = description
	result.path = path
	return result
end

local soters = require("telescope.sorters")
local config = require("telescope.config")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

M.git_related = function(path, from, to, opts)
	local blame = git_blame(path, from, to)
	if blame == nil then
		return nil
	end

	local items = {}
	local cache = {}
	for hash, _ in pairs(blame) do
		local show = git_show(hash)

		for _, path in ipairs(show.path) do
			if cache[path] == nil then
				cache[path] = git_blame(path)
			end

			if cache[path] and cache[path][hash] then
				for _, pos in ipairs(cache[path][hash]) do
					items[#items + 1] = { filename = path, lnum = pos.from, col = 1, text = hash }
				end
			end
		end
	end

	opts = opts or {}
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

vim.cmd("sign define BlameSign linehl=DiffText")

M.blame_highlight = function(path, line)
	local command = { "git", "blame", "-l", "-s", "--", path }

	local blame = vim.fn.systemlist(command)
	if vim.v.shell_error ~= 0 then
		return nil
	end

	for i, v in ipairs(blame) do
		local hash = string.match(v, "%S+")
		blame[i] = hash
	end

	local hash = blame[line]
	for i, v in ipairs(blame) do
		if v == hash then
			vim.cmd(string.format("sign place %d line=%d name=BlameSign group=BlameSign", i, i))
		end
	end
end

M.blame_clear_highlight = function()
	vim.cmd(string.format("sign unplace * group=BlameSign buffer=%d", vim.fn.bufnr()))
end

vim.api.nvim_create_user_command("GitRelated", function(opts)
	if opts.range == 0 then
		M.git_related(vim.fn.expand("%:p"))
	else
		M.git_related(vim.fn.expand("%:p"), opts.line1, opts.line2)
	end
end, { range = true })

vim.api.nvim_create_user_command("BlameHighlight", function(opts)
	M.blame_highlight(vim.fn.expand("%:p"), opts.line1)
end, { range = true })

vim.api.nvim_create_user_command("BlameClearHighlight", function(opts)
	M.blame_clear_highlight()
end, {})

return M
