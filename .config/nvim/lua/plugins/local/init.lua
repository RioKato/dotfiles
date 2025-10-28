local root = "plugins.local"

require(root .. ".hover").setup()

local Tmux = require(root .. ".tmux")

vim.keymap.set("n", "<C-w>z", function()
    local opts = {
        on_open = function()
            if not Tmux:zoomed() then
                Tmux:zoom()
            end
        end,

        on_close = function()
            if Tmux:zoomed() then
                Tmux:zoom()
            end
        end,
    }

    opts = Tmux:enabled() and opts or {}
    Snacks.zen.zen(opts)
end)
