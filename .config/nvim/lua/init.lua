vim.o.inccommand = "split"
vim.o.jumpoptions = "stack"

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd("clearjumps")
	end,
})

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

vim.keymap.set("n", "<C-l>", function()
	if vim.bo.filetype ~= "qf" then
		vim.cmd("copen")
	else
		vim.cmd("cclose")
	end
end)
vim.keymap.set("n", "<C-n>", "<cmd>cnext<cr>")
vim.keymap.set("n", "<C-p>", "<cmd>cprev<cr>")
vim.keymap.set("n", "<C-a>", "<cmd>caddexpr printf('%s:%d:%d:%s', expand('%'), line('.'), col('.'), getline('.'))<cr>")

vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "qf",
	callback = function()
		vim.keymap.set("n", "q", "<cmd>cclose<cr>", { buffer = true })
		vim.keymap.set("n", "<C-o>", "<cmd>colder<cr>", { buffer = true })
		vim.keymap.set("n", "<C-i>", "<cmd>cnewer<cr>", { buffer = true })
		vim.keymap.set("n", "<enter>", "<cmd>.cc<cr>", { buffer = true })
	end,
})

local lazypath = string.format("%s/lazy/lazy.nvim", vim.fn.stdpath("data"))
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ "folke/lazy.nvim" },

	{
		"t9md/vim-quickhl",

		config = function()
			vim.keymap.set("n", "<C-t>", "<plug>(quickhl-manual-this)")
			vim.keymap.set("x", "<C-t>", "<plug>(quickhl-manual-this)")
			vim.keymap.set("n", "<space>m", "<plug>(quickhl-manual-reset)")
		end,
	},

	{ "deris/vim-shot-f" },

	{ "machakann/vim-sandwich" },

	{ "tpope/vim-commentary" },

	{ "itchyny/vim-qfedit" },

	{
		"williamboman/mason.nvim",

		config = function()
			require("mason").setup()
		end,
	},

	{
		"hrsh7th/cmp-nvim-lsp",
		dependencies = { "hrsh7th/nvim-cmp" },
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
		},

		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local mason_lspconfig = require("mason-lspconfig")
			local lspconfig = require("lspconfig")

			mason_lspconfig.setup({
				ensure_installed = { "pyright" },
			})

			mason_lspconfig.setup_handlers({
				function(server)
					lspconfig[server].setup({
						capabilities = capabilities,
					})
				end,
			})

			for _, server in ipairs({ "clangd", "rust_analyzer", "gopls", "codeqlls", "jdtls" }) do
				lspconfig[server].setup({
					capabilities = capabilities,
				})
			end
		end,
	},

	{
		"jose-elias-alvarez/null-ls.nvim",
		-- "nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },

		config = function()
			local null_ls = require("null-ls")
			null_ls.builtins.formatting.prettier.filetypes = { "markdown" }

			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.autopep8,
					null_ls.builtins.formatting.prettier,
				},
			})
		end,
	},

	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"jose-elias-alvarez/null-ls.nvim",
			-- "nvimtools/none-ls.nvim",
		},
		event = { "BufReadPre", "BufNewFile" },

		config = function()
			require("mason-null-ls").setup({
				ensure_installed = nil,
				automatic_installation = true,
			})
		end,
	},

	{ "nvim-treesitter/nvim-treesitter" },

	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },

		config = function()
			local actions = require("telescope.actions")
			local builtin = require("telescope.builtin")
			local lsputils = require("lsputils")

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-l>"] = actions.send_to_qflist + actions.open_qflist,
						},
					},
					path_display = { "shorten" },
					layout_config = {
						width = 0.99,
						height = 0.99,
					},
				},
			})

			local opts = { noremap = true, silent = true }

			vim.keymap.set("n", "<space>f", builtin.find_files, opts)
			vim.keymap.set("n", "<space>b", builtin.buffers, opts)
			vim.keymap.set("n", "<space>g", builtin.live_grep, opts)
			vim.keymap.set("n", "<space>G", builtin.current_buffer_fuzzy_find, opts)
			vim.keymap.set("n", "<C-s>", builtin.grep_string, opts)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.bufnr }
					vim.keymap.set("n", "<C-j>", builtin.lsp_definitions, opts)
					vim.keymap.set("n", "<C-k>", builtin.lsp_references, opts)
					vim.keymap.set("n", "<C-h>", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<space>h", lsputils.symbols, opts)
					vim.keymap.set("n", "<space>d", builtin.diagnostics, opts)
					vim.keymap.set("n", "<space><space>", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
				end,
			})
		end,
	},

	{
		"hrsh7th/cmp-vsnip",
		dependencies = { "hrsh7th/vim-vsnip" },
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-vsnip",
		},

		config = function()
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
					["<tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end),
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "vsnip" },
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},

	{
		"ray-x/lsp_signature.nvim",

		config = function()
			require("lsp_signature").setup({
				floating_window = false,
				hint_enable = true,
				hint_prefix = "",
			})
		end,
	},

	{
		"tpope/vim-fugitive",

		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "fugitiveblame",
				callback = function()
					vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true })
					vim.keymap.set("n", "<tab>", "~", { buffer = true, remap = true })
				end,
			})

			vim.keymap.set("n", "mt", function()
				if vim.bo.filetype ~= "fugitiveblame" then
					vim.cmd("Git blame -w")
				else
					vim.cmd("close")
				end
			end, {})
		end,
	},

	{
		"junegunn/gv.vim",
		dependencies = { "tpope/vim-fugitive" },

		config = function()
			vim.keymap.set("n", "ml", "<cmd>GV<cr>", {})
			vim.keymap.set("n", "mf", function()
				vim.cmd(string.format("GV -- %s", vim.fn.expand("%:p")))
			end, {})
			vim.keymap.set("n", "ms", function()
				vim.cmd(string.format("GV -S %s", vim.fn.expand("<cword>")))
			end, {})
		end,
	},

	{
		"linrongbin16/gitlinker.nvim",

		config = function()
			require("gitlinker").setup()
		end,
	},

	{
		"segeljakt/vim-silicon",

		config = function()
			vim.g.silicon = {
				["theme"] = "Dracula",
				["font"] = "Hack",
				["background"] = "#AAAAFF",
				["shadow-color"] = "#555555",
				["line-pad"] = 2,
				["pad-horiz"] = 80,
				["pad-vert"] = 100,
				["shadow-blur-radius"] = 0,
				["shadow-offset-x"] = 0,
				["shadow-offset-y"] = 0,
				["line-number"] = true,
				["round-corner"] = true,
				["window-controls"] = true,
				["to-clipboard"] = true,
				["output"] = "/tmp/silicon.png",
			}
		end,
	},

	{
		"img-paste-devs/img-paste.vim",

		config = function()
			vim.g.mdip_imgdir = "image"
			vim.g.mdip_imgdir_intext = "image"

			vim.api.nvim_create_user_command("ImagePaste", function()
				vim.fn["mdip#MarkdownClipboardImage"]()
			end, {})

			vim.api.nvim_create_user_command("ImageOpen", function()
				vim.fn.system({ "xdg-open", vim.fn.expand("<cfile>") })
			end, {})

			vim.api.nvim_create_autocmd({ "FileType" }, {
				pattern = "markdown",
				callback = function()
					vim.keymap.set("n", "gp", "<cmd>ImagePaste<cr>", { buffer = true })
					vim.keymap.set("n", "go", "<cmd>ImageOpen<cr>", { buffer = true })
				end,
			})
		end,
	},

	{
		"voldikss/vim-translator",

		config = function()
			vim.g.translator_target_lang = "ja"
		end,
	},

	{ "liuchengxu/graphviz.vim" },
})
