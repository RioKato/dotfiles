local root = "plugins.local"

require(root .. ".hover").setup()

local Tmux = require(root .. ".tmux")

vim.keymap.set("n", "<C-w>z", function()
    local opts = {
        toggles = {
            dim = false,
        },

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

    if not Tmux:enabled() then
        opts.on_open = nil
        opts.on_close = nil
    end

    Snacks.zen(opts)
end)
