local esc = "<C-u>"

vim.keymap.set({ "", "i" }, esc, function()
    io.write("\7")
    local code = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
    vim.fn.feedkeys(code, "n")
end)

vim.keymap.set("c", esc, function()
    io.write("\7")
    local code = vim.api.nvim_replace_termcodes("<C-c>", true, false, true)
    vim.fn.feedkeys(code, "n")
end)

vim.keymap.set("t", esc, function()
    io.write("\7")
    local code = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
    vim.fn.feedkeys(code, "n")
end)

vim.keymap.set({ "", "i", "c" }, "<C-c>", '<cmd>echoerr "Don\'t use C-c"<cr>')
