local M = {}

function M.setup()
    local root = "plugins.local"
    require(root .. ".hover").setup()
end

return M
