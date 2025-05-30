local esc = "<C-u>"

vim.keymap.set({ "", "i" }, esc, function()
    local key = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
    vim.api.nvim_feedkeys(key, "n", false)
    io.write("\7")
end)

vim.keymap.set("c", esc, function()
    local key = vim.api.nvim_replace_termcodes("<C-c>", true, false, true)
    vim.api.nvim_feedkeys(key, "n", false)
    io.write("\7")
end)

vim.keymap.set("t", esc, function()
    local key = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
    vim.api.nvim_feedkeys(key, "n", false)
    io.write("\7")
end)

vim.keymap.set({ "", "i", "c" }, "<C-c>", '<cmd>echoerr "Don\'t use C-c"<cr>')
