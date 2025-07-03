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

config.disable_default_key_bindings = true
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    { key = ";", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },

    { key = "s", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "c", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
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

    { key = "q", mods = "LEADER", action = wezterm.action.QuickSelect },
}

local keybinds = {
    copy_mode = {
        {
            key = "Enter",
            mods = "NONE",
            action = wezterm.action.Multiple({
                { CopyTo = "Clipboard" },
                { CopyMode = "Close" },
            }),
        },
        {
            key = "/",
            mods = "NONE",
            action = wezterm.action.Multiple({
                wezterm.action.CopyMode("ClearPattern"),
                wezterm.action.Search({ CaseInSensitiveString = "" }),
            }),
        },
    },

    search_mode = {
        {
            key = "Escape",
            mods = "NONE",
            action = wezterm.action.Multiple({
                wezterm.action.CopyMode("ClearPattern"),
                wezterm.action.CopyMode("Close"),
            }),
        },
    },
}

local copy_mode = wezterm.gui.default_key_tables().copy_mode
local search_mode = wezterm.gui.default_key_tables().search_mode

for _, keybind in ipairs(keybinds.copy_mode) do
    table.insert(copy_mode, keybind)
end

for _, keybind in ipairs(keybinds.search_mode) do
    table.insert(search_mode, keybind)
end

config.key_tables = {
    copy_mode = copy_mode,
    search_mode = search_mode,
}

return config
