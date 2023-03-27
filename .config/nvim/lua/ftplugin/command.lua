telescope.load_extension("lookup_ip")
vim.keymap.set("n", "<space>l", telescope.extensions.lookup_ip.lookup_ip_n, opts)
vim.keymap.set("i", "<C-l>", telescope.extensions.lookup_ip.lookup_ip_i, opts)
vim.api.nvim_create_user_command("LookupIP", telescope.extensions.lookup_ip.lookup_ip_n, {})

telescope.load_extension("pensnippet")
vim.keymap.set("n", "<space>p", telescope.extensions.pensnippet.pensnippet, opts)
vim.api.nvim_create_user_command("Pensnippet", telescope.extensions.pensnippet.pensnippet, {})

local insert_home_path = require("insert_home_path")
vim.keymap.set("i", "<C-t>", insert_home_path.insert_home_path_i, opts)
