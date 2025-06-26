local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font_size = 12.0
config.window_background_opacity = 0.9
config.color_scheme = "Bamboo"
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.audible_bell = "Disabled"

config.disable_default_key_bindings = true
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    { key = ";", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },

    { key = "s", mods = "LEADER", action = wezterm.action.SplitVertical },
    { key = "v", mods = "LEADER", action = wezterm.action.SplitHorizontal },
    { key = "c", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
    { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
    { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },

    { key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },

    { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
    { key = "]", mods = "LEADER", action = wezterm.action.PasteFrom("Clipboard") },
}

return config
