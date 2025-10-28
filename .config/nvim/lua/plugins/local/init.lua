local root = "plugins.local"

local init = {}

function init.hover()
    require(root .. ".hover").setup()
end

function init.tmux()
    local tmux = require(root .. ".tmux")

    tmux.setup()

    vim.keymap.set("n", "<C-w>z", function()
        local opts = {
            toggles = {
                dim = false,
            },
        }

        if tmux.active() then
            opts.on_open = tmux.zoom.on
            opts.on_close = tmux.zoom.off
        end

        Snacks.zen(opts)
    end)
end

function init:all()
    self.hover()
    self.tmux()
end

init:all()
