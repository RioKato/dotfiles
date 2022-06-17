vim.o.inccommand = "split"
vim.o.jumpoptions = "stack"
vim.cmd([[ autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup = 'IncSearch', timeout = 200 } ]])
vim.diagnostic.config({
	virtual_text = false,
	signs = false,
	underline = true,
})

local packer = require("packer")
packer.startup(function()
	use("wbthomason/packer.nvim")
	use("ckipp01/stylua-nvim")

	use("neovim/nvim-lspconfig")
	use("williamboman/nvim-lsp-installer")
	use({
		"nvim-treesitter/nvim-treesitter",
		requires = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
		},
	})
	use({
		"nvim-telescope/telescope.nvim",
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
			{ "hrsh7th/cmp-vsnip" },
			{ "hrsh7th/vim-vsnip" },
		},
	})
	use("xiyaowong/nvim-cursorword")
	use("lukas-reineke/indent-blankline.nvim")
	use("tversteeg/registers.nvim")
	use("ellisonleao/glow.nvim")
	use({
		"pwntester/codeql.nvim",
		requires = {
			{ "MunifTanjim/nui.nvim" },
			{ "nvim-lua/telescope.nvim" },
			{ "kyazdani42/nvim-web-devicons" },
		},
	})
end)

stylua = require("stylua-nvim")
vim.cmd([[ autocmd BufWritePre init.lua silent! lua stylua.format_file() ]])

local nvim_treesitter = require("nvim-treesitter.configs")
nvim_treesitter.setup({
	ensure_installed = { "c", "rust", "python" },
	sync_install = false,
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
	textobjects = {
		select = {
			enable = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["ap"] = "@parameter.outer",
				["ip"] = "@parameter.inner",
			},
		},
	},
})

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

telescope_builtin = require("telescope.builtin")
local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap("n", "<space>f", "<cmd>lua telescope_builtin.find_files()<cr>", opts)
vim.api.nvim_set_keymap("n", "<space>b", "<cmd>lua telescope_builtin.buffers()<cr>", opts)
vim.api.nvim_set_keymap("n", "<space>r", "<cmd>lua telescope_builtin.registers()<cr>", opts)
vim.api.nvim_set_keymap("n", "<space>g", "<cmd>lua telescope_builtin.live_grep()<cr>", opts)
vim.api.nvim_set_keymap("n", "<C-s>", "<cmd>lua telescope_builtin.grep_string()<cr>", opts)

local on_attach = function(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-j>", "<cmd>lua telescope_builtin.lsp_definitions()<cr>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua telescope_builtin.lsp_references()<cr>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-h>", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-n>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>h", "<cmd>lua telescope_builtin.lsp_document_symbols()<cr>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>d", "<cmd>lua telescope_builtin.diagnostics()<cr>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<space><space>", "<cmd>lua vim.lsp.buf.format { async = true }<cr>", opts)
end

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
	}),
})

local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require("lspconfig")

lspconfig.clangd.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.pylsp.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.rust_analyzer.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.gopls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

lspconfig.tsserver.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = vim.loop.cwd,
})

lspconfig.codeqlls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})

local codeql = require("codeql")
codeql.setup({})
