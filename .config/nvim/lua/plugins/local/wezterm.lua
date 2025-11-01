local wezterm = {}

function wezterm.exec(cmd)
    vim.system({ "wezterm", unpack(cmd) })
end

function wezterm:cli(cmd)
    self:exec({ "cli", unpack(cmd) })
end

function wezterm:activatePaneDirection(direction)
    local directions = { "Up", "Down", "Left", "Right", "Next", "Prev" }
    assert(vim.tbl_contains(directions, direction))

    self:cli({ "activate-pane-direction", direction })
end

function wezterm:zoomPane(opt)
    opt = opt == nil and "--toggle" or (opt and "--zoom" or "--unzoom")
    self:cli({ "zoom-pane", opt })
end

local wrapper = {}

function wrapper.go(hjkl)
    local map = {
        h = "Left",
        j = "Down",
        k = "Up",
        l = "Right",
    }

    assert(vim.tbl_contains(vim.tbl_keys(map), hjkl))

    local win = vim.api.nvim_get_current_win()

    vim.cmd.wincmd(hjkl)

    if win == vim.api.nvim_get_current_win() then
        wezterm:activatePaneDirection(map[hjkl])
    end
end

function wrapper.zoom()
    local opts = {
        toggles = {
            dim = false,
        },
        on_open = function()
            wezterm:zoomPane(true)
        end,
        on_close = function()
            wezterm:zoomPane(false)
        end,
    }

    Snacks.zen(opts)
end

local M = {}

function M.setup(prefix)
    local keys = {
        {
            "h",
            function()
                wrapper.go("h")
            end,
        },
        {
            "j",
            function()
                wrapper.go("j")
            end,
        },
        {
            "k",
            function()
                wrapper.go("k")
            end,
        },
        {
            "l",
            function()
                wrapper.go("l")
            end,
        },
        {
            "z",
            wrapper.zoom,
        },
    }

    for _, key in ipairs(keys) do
        vim.keymap.set("n", prefix .. key[1], key[2])
    end
end

return M
