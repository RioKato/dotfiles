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

vim.api.nvim_create_user_command("ChangeBase", function()
    local cword = vim.fn.expand("<cword>")
    local base = 0
    local expr = ""

    if cword:match("^0x[a-fA-F0-9]+$") then
        base = 16
        expr = "ciw%d"
    elseif cword:match("^[0-9]+$") then
        base = 10
        expr = "ciw0x%x"
    else
        error("not number")
    end

    vim.cmd.normal(string.format(expr, tonumber(cword, base)))
end, {})

vim.api.nvim_create_user_command("W3M", "terminal w3m", {})
