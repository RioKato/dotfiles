local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({ "Inconsolata Nerd Font" })
config.font_size = 12.0
config.warn_about_missing_glyphs = false

config.window_background_opacity = 0.9
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.color_scheme = "Bamboo"

config.audible_bell = "Disabled"
config.skip_close_confirmation_for_processes_named = {}

local function uncapture(name, opts)
    assert(opts.mods == "LEADER")

    local sendKeys = wezterm.action.Multiple({
        wezterm.action.SendKey({ key = config.leader.key, mods = config.leader.mods }),
        wezterm.action.SendKey({ key = opts.key }),
    })

    local action = opts.action

    opts.action = wezterm.action_callback(function(win, pane)
        local found = pane:get_foreground_process_name():find(name)
        win:perform_action(found and sendKeys or action, pane)
    end)

    return opts
end

config.disable_default_key_bindings = true
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    { key = ";", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },

    { key = "s", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    uncapture("nvim", { key = "c", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) }),
    uncapture("nvim", { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState }),
    uncapture("nvim", { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") }),
    uncapture("nvim", { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") }),
    uncapture("nvim", { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") }),
    uncapture("nvim", { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") }),

    { key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },

    { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
    { key = "]", mods = "LEADER", action = wezterm.action.PasteFrom("Clipboard") },

    { key = "q", mods = "LEADER", action = wezterm.action.QuickSelect },
    { key = "d", mods = "LEADER", action = wezterm.action.ShowDebugOverlay },

    { key = "1", mods = "LEADER", action = require("spawnsh") },
}

return config
