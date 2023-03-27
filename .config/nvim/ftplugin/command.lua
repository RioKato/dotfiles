local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
	error("Telescope interface requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local opts = { noremap = true, silent = true }

telescope.load_extension("lookup_ip")
vim.keymap.set("n", "<C-i>", telescope.extensions.lookup_ip.lookup_ip, opts)

telescope.load_extension("pensnippet")
vim.keymap.set("n", "<C-p>", telescope.extensions.pensnippet.pensnippet, opts)

local insert_home_path = require("insert_home_path")
vim.keymap.set("n", "<C-t>", function()
	insert_home_path.insert_home_path({})
end, opts)
