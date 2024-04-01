local M = {}

local function git_blame(hash, path)
	local blame = vim.fn.systemlist({ "git", "blame", "-l", "-s", hash, "--", path })
	if vim.v.shell_error ~= 0 then
		-- error("git-blame failed")
		return {}
	end

	for i, v in ipairs(blame) do
		local hash = string.match(v, "%S+")
		if hash == nil then
			error("git-blame format is invalid")
		end

		blame[i] = hash
	end

	return blame
end

local function git_show(hash)
	local show = vim.fn.systemlist({ "git", "show", "--name-only", "--oneline", hash })
	if vim.v.shell_error ~= 0 then
		-- error("git-show failed")
		return {}
	end

	if #show < 2 then
		error("git-show format is invalid")
	end

	local result = {}

	for i = 2, #show do
		result[#result + 1] = show[i]
	end

	return result
end

local function git_show_head()
	local head = vim.fn.systemlist({ "git", "show", "--format=%H", "--no-patch", "HEAD" })
	if vim.v.shell_error ~= 0 then
		error("git-show-head failed")
	end

	if #head ~= 1 then
		error("git-show-head format is invalid")
	end

	return head[1]
end

local function git_rev_parse()
	local rev_parse = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
	if vim.v.shell_error ~= 0 then
		error("git-rev-parse failed")
	end

	if #rev_parse ~= 1 then
		error("git-rev-parse format is invalid")
	end

	return rev_parse[1]
end

local GitCache = {
	cblame = {},
	cshow = {},
	cgroup_by_blame = {},

	blame = function(self, hash, path)
		if self.cblame[hash] == nil then
			self.cblame[hash] = {}
		end

		if self.cblame[hash][path] == nil then
			self.cblame[hash][path] = git_blame(hash, path)
		end

		return self.cblame[hash][path]
	end,

	show = function(self, hash)
		if self.cshow[hash] == nil then
			self.cshow[hash] = git_show(hash)
		end

		return self.cshow[hash]
	end,

	group_by_blame = function(self, hash, path)
		if self.cgroup_by_blame[hash] == nil then
			self.cgroup_by_blame[hash] = {}
		end

		if self.cgroup_by_blame[hash][path] == nil then
			local blame = self:blame(hash, path)
			local result = {}

			for i, v in ipairs(blame) do
				if result[v] == nil then
					result[v] = { { from = i, to = i } }
				else
					line = result[v]
					if line[#line].to + 1 == i then
						line[#line].to = i
					else
						line[#line + 1] = { from = i, to = i }
					end
				end
			end

			self.cgroup_by_blame[hash][path] = result
		end

		return self.cgroup_by_blame[hash][path]
	end,
}

local soters = require("telescope.sorters")
local config = require("telescope.config")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

M.list = function(opts)
	local placed = vim.fn.sign_getplaced(vim.fn.bufnr(), { group = "*" })

	local signs = {}
	for _, v in ipairs(placed[1].signs) do
		if v.name == "GitRelatedSelectSign" then
			signs[v.group] = true
		end
	end

	local sorted = {}
	local root = git_rev_parse()
	local head = git_show_head()
	for hash, _ in pairs(signs) do
		local show = GitCache:show(hash)

		for _, path in ipairs(show) do
			path = string.format("%s/%s", root, path)
			local group = GitCache:group_by_blame(head, path)[hash] or {}

			for _, pos in ipairs(group) do
				if sorted[path] == nil then
					sorted[path] = {}
				end

				local temp = sorted[path]
				temp[#temp + 1] = pos
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
			items[#items + 1] = { filename = path, lnum = pos.from, col = 1, text = "" }
		end
	end

	opts = opts or {}
	opts.show_line = false

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

vim.fn.sign_define("GitRelatedSelectSign", { linehl = "DiffText" })
vim.fn.sign_define("GitRelatedMark2", { text = "2" })
vim.fn.sign_define("GitRelatedMark3", { text = "3" })
vim.fn.sign_define("GitRelatedMark4", { text = "4" })
vim.fn.sign_define("GitRelatedMark5", { text = "5" })
vim.fn.sign_define("GitRelatedMark6", { text = "6" })
vim.fn.sign_define("GitRelatedMark7", { text = "7" })
vim.fn.sign_define("GitRelatedMark8", { text = "8" })
vim.fn.sign_define("GitRelatedMark9", { text = "9" })
vim.fn.sign_define("GitRelatedMark*", { text = "*" })

M.select = function(path, line1, line2)
	local blame = GitCache:blame(git_show_head(), path)

	if line2 == nil then
		line2 = line1
	end

	local selected = {}
	for i = line1, line2 do
		selected[blame[i]] = true
	end

	local bufnr = vim.fn.bufnr()

	for hash, _ in pairs(selected) do
		local placed = vim.fn.sign_getplaced(bufnr, { group = hash })

		if #placed[1].signs == 0 then
			for i, v in ipairs(blame) do
				if v == hash then
					vim.fn.sign_place(0, hash, "GitRelatedSelectSign", bufnr, { lnum = i })
				end
			end
		else
			vim.fn.sign_unplace(hash, { buffer = bufnr })
		end
	end
end

M.clear = function()
	local bufnr = vim.fn.bufnr()
	local placed = vim.fn.sign_getplaced(bufnr, { group = "*" })

	local unplaced = {}
	for _, v in ipairs(placed[1].signs) do
		if v.name == "GitRelatedSelectSign" then
			if not unplaced[v.group] then
				vim.fn.sign_unplace(v.group, { buffer = bufnr })
				unplaced[v.group] = true
			end
		end
	end
end

M.mark = function(path)
	local bufnr = vim.fn.bufnr()
	local head = git_show_head()
	local placed = vim.fn.sign_getplaced(bufnr, { group = "GitRelatedMark" })

	if #placed[1].signs == 0 then
		local blame = GitCache:blame(head, path)
		local root = git_rev_parse()

		for i, hash in ipairs(blame) do
			local show = GitCache:show(hash)
			local count = 0

			for _, path in ipairs(show) do
				path = string.format("%s/%s", root, path)
				local group = GitCache:group_by_blame(head, path)
				if group[hash] then
					count = count + 1
				end
			end

			local mark = nil
			if count > 1 and count <= 9 then
				mark = string.format("GitRelatedMark%d", count)
			elseif count > 9 then
				mark = "GitRelatedMark*"
			end

			if mark then
				vim.fn.sign_place(0, "GitRelatedMark", mark, bufnr, { lnum = i })
			end
		end
	else
		vim.fn.sign_unplace("GitRelatedMark", { buffer = bufnr })
	end
end

vim.api.nvim_create_user_command("GitRelatedList", M.list, {})
vim.api.nvim_create_user_command("GitRelatedSelect", function(opts)
	M.select(vim.fn.expand("%:p"), opts.line1, opts.line2)
end, { range = true })
vim.api.nvim_create_user_command("GitRelatedClear", M.clear, {})
vim.api.nvim_create_user_command("GitRelatedMark", function()
	M.mark(vim.fn.expand("%:p"))
end, {})

return M
