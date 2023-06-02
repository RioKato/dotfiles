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
		tag = "0.1.1",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
			{ "kyazdani42/nvim-web-devicons" },
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
	use("lukas-reineke/indent-blankline.nvim")
	use("tversteeg/registers.nvim")
end)

local indent_blankline = require("indent_blankline")
indent_blankline.setup({
	show_current_context = true,
})

local telescope = require("telescope")
telescope.load_extension("fzf")

telescope.setup({
	defaults = {
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

local telescope_builtin = require("telescope.builtin")
local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<space>f", telescope_builtin.find_files, opts)
vim.keymap.set("n", "<space>b", telescope_builtin.buffers, opts)
vim.keymap.set("n", "<space>r", telescope_builtin.registers, opts)
vim.keymap.set("n", "<space>g", telescope_builtin.live_grep, opts)
vim.keymap.set("n", "<space>G", telescope_builtin.current_buffer_fuzzy_find, opts)
vim.keymap.set("n", "<C-s>", telescope_builtin.grep_string, opts)

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		local opts = { buffer = ev.bufnr }
		vim.keymap.set("n", "<C-j>", telescope_builtin.lsp_definitions, opts)
		vim.keymap.set("n", "<C-k>", telescope_builtin.lsp_references, opts)
		vim.keymap.set("n", "<C-h>", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<C-n>", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<space>h", telescope_builtin.lsp_document_symbols, opts)
		vim.keymap.set("n", "<space>t", telescope_builtin.tagstack, opts)
		vim.keymap.set("n", "<space>d", telescope_builtin.diagnostics, opts)
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

local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()
local lspconfig = require("lspconfig")

local servers = { "clangd", "pyright", "rust_analyzer", "gopls" }

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
