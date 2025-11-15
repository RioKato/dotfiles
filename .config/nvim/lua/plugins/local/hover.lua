local Layout = {}

function Layout.new()
	local obj = {
		buf = nil,
		win = nil,
	}

	setmetatable(obj, { __index = Layout })
	return obj
end

function Layout:open(opts)
	if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
		self.buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(self.buf, "hover")
		vim.bo[self.buf].modifiable = false
		vim.bo[self.buf].filetype = "markdown"
	end

	if not self.win or not vim.api.nvim_win_is_valid(self.win) then
		self.win = vim.api.nvim_open_win(self.buf, false, opts)
	else
		local wins = vim.api.nvim_tabpage_list_wins(0)

		if not vim.tbl_contains(wins, self.win) then
			vim.api.nvim_win_close(self.win, false)
			self.win = vim.api.nvim_open_win(self.buf, false, opts)
		end
	end
end

function Layout:close()
	if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
		vim.api.nvim_buf_delete(self.buf, { force = true, unload = true })
	end

	if self.win and vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_win_close(self.win, false)
	end

	self.buf = nil
	self.win = nil
end

function Layout:write(lines)
	vim.bo[self.buf].modifiable = true
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, true, lines)
	vim.bo[self.buf].modifiable = false
	vim.api.nvim_win_set_cursor(self.win, { 1, 0 })
end

function Layout:render() end

function Layout:hover(opts)
	local encoding = vim.bo.fileencoding

	if encoding == "" then
		encoding = "utf-8"
	end

	local position = vim.lsp.util.make_position_params(0, encoding)

	vim.lsp.buf_request_all(0, "textDocument/hover", position, function(arg)
		vim.iter(pairs(arg)):each(function(id, response)
			if response.result then
				local lines = vim.lsp.util.convert_input_to_markdown_lines(response.result.contents)
				self:open(opts)
				self:write(lines)
				self:render()
			end
		end)
	end)
end

local Hover = {}

function Hover.new(opts)
	local obj = {
		layout = Layout.new(),
		opts = opts,
	}

	setmetatable(obj, { __index = Hover })
	return obj
end

function Hover:open()
	self.layout:hover(self.opts)
end

function Hover:close()
	self.layout:close()
end

function Hover:set(render)
	self.layout.render = render
end

local Render = {
	plugin = {
		["render-markdown.core.ui"] = function(module)
			if module.update then
				return function(self)
					module.update(self.buf, self.win, "hover", false)
				end
			end
		end,

		["markview"] = function(module)
			if module.strict_render then
				return function(self)
					module.strict_render:clear(self.buf)
					module.strict_render:render(self.buf)
				end
			end
		end,
	},
}

function Render:get()
	for name, callback in pairs(self.plugin) do
		local ok, module = pcall(require, name)

		if ok then
			local render = callback(module)

			if render then
				return render
			end
		end
	end
end

local M = {
	Hover = Hover,
	Render = Render,
}

local default = {
	win = {
		split = "below",
		win = -1,
		style = "minimal",
		height = 5,
	},
	render = nil,
}

function M.setup(opts)
	opts = vim.tbl_deep_extend("force", default, opts or {})
	local hover = Hover.new(opts.win)
	local render = opts.render or Render:get()

	if render then
		hover:set(render)
	end

	vim.lsp.buf.hover = function()
		hover:open()
	end

	vim.api.nvim_create_user_command("HoverClose", function()
		hover:close()
	end, {})
end

return M
