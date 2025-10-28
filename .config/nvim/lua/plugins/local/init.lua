local root = "plugins.local"

require(root .. ".hover").setup()

local tmux = require(root .. ".tmux")

vim.keymap.set("n", "<C-w>z", function()
    local enabled = tmux.Tmux:enabled()

    local function on_open()
        tmux.Zoom:on()
    end

    local function on_close()
        tmux.Zoom:off()
    end

    local opts = {
        toggles = {
            dim = false,
        },

        on_open = enabled and on_open or nil,
        on_close = enabled and on_close or nil,
    }

    Snacks.zen(opts)
end)
