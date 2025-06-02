vim.api.nvim_create_user_command("W3M", function()
    vim.cmd("lcd ~/Downloads")
    vim.cmd("terminal w3m")
end, {})
