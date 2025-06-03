vim.api.nvim_create_user_command("Clean", function(opts)
    local winbufnrs = {}

    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        winbufnrs[vim.api.nvim_win_get_buf(winid)] = true
    end

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if not winbufnrs[bufnr] then
            pcall(vim.api.nvim_buf_delete, bufnr, { force = opts.bang })
        end
    end
end, { bang = true })

vim.api.nvim_create_user_command("W3M", "terminal w3m", {})
