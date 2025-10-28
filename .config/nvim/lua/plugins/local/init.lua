local root = "plugins.local"

local init = {}

function init.hover()
    require(root .. ".hover").setup()
end

function init.tmux()
    local tmux = require(root .. ".tmux")

    vim.keymap.set("n", "<C-w>z", function()
        local active = tmux.active()

        local opts = {
            toggles = {
                dim = false,
            },

            on_open = active and tmux.zoom.on or nil,
            on_close = active and tmux.zoom.off or nil,
        }

        Snacks.zen(opts)
    end)
end

function init:all()
    self.hover()
    self.tmux()
end

init:all()
