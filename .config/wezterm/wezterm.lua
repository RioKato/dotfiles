local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font_size = 12.0
config.use_ime = true
config.window_background_opacity = 0.85
config.window_decorations = "RESIZE"

config.disable_default_key_bindings = true

config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
    { key = ";", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
    { key = "s", mods = "LEADER", action = wezterm.action.SplitVertical },
    { key = "v", mods = "LEADER", action = wezterm.action.SplitHorizontal },
    { key = "c", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
    { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
    { key = "]", mods = "LEADER", action = wezterm.action.PasteFrom("Clipboard") },
    { key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "LEADER", action = wezterm.action.MoveTabRelative(1) },
    { key = "p", mods = "LEADER", action = wezterm.action.MoveTabRelative(-1) },
}

return config
