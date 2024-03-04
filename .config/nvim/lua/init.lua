vim.o.inccommand = "split"

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

vim.diagnostic.config({
	virtual_text = false,
	signs = false,
	underline = true,
})

local packer = require("packer")
packer.startup(function()
	use("wbthomason/packer.nvim")

	use("neovim/nvim-lspconfig")
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = { "nvim-lua/plenary.nvim" },
	})
	use("nvim-treesitter/nvim-treesitter")
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		requires = {
			{ "nvim-lua/plenary.nvim" },
		},
	})
	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		run = "make",
		requires = {
			{ "nvim-telescope/telescope.nvim" },
		},
	})
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-cmdline" },
			{ "hrsh7th/cmp-vsnip" },
			{ "hrsh7th/vim-vsnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	})
	use("xiyaowong/nvim-cursorword")
	use("tversteeg/registers.nvim")
	use("ray-x/lsp_signature.nvim")
end)

local telescope = require("telescope")
telescope.load_extension("fzf")

telescope.setup({
	defaults = {
		path_display = { "shorten" },
		layout_config = {
			width = 0.99,
			height = 0.99,
		},
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})

local builtin = require("telescope.builtin")
local opts = { noremap = true, silent = true }
local lsputil = require("lsputil")

vim.api.nvim_create_user_command("LspUtilCallgraph", function(opts)
	lsputil.callgraph(opts.fargs[1])
end, { nargs = 1 })

vim.keymap.set("n", "<space>f", builtin.find_files, opts)
vim.keymap.set("n", "<space>b", builtin.buffers, opts)
vim.keymap.set("n", "<space>r", builtin.registers, opts)
vim.keymap.set("n", "<space>g", builtin.live_grep, opts)
vim.keymap.set("n", "<space>G", builtin.current_buffer_fuzzy_find, opts)
vim.keymap.set("n", "<C-s>", builtin.grep_string, opts)

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		local opts = { buffer = ev.bufnr }
		vim.keymap.set("n", "<C-j>", builtin.lsp_definitions, opts)
		vim.keymap.set("n", "<C-k>", builtin.lsp_references, opts)
		vim.keymap.set("n", "<C-h>", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<C-n>", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<space>h", lsputil.symbols, opts)
		vim.keymap.set("n", "<space>d", builtin.diagnostics, opts)
		vim.keymap.set("n", "<space><space>", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	window = {},
	mapping = {
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<cr>"] = cmp.mapping.confirm({ select = true }),
		["<tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end,
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "vsnip" },
	}, {
		{ name = "buffer" },
		{ name = "path" },
	}),
})

local lsp_signature = require("lsp_signature")
lsp_signature.setup({
	floating_window = false,
	hint_enable = true,
})

local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()
local lspconfig = require("lspconfig")

local servers = { "clangd", "pyright", "rust_analyzer", "gopls", "codeqlls" }

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		capabilities = capabilities,
	})
end

lspconfig.tsserver.setup({
	capabilities = capabilities,
	root_dir = vim.loop.cwd,
})

local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.autopep8,
		null_ls.builtins.formatting.prettier,
	},
})
