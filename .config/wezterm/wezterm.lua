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

local leader = { key = "q", mods = "CTRL" }

local function register_event(event, key, actions)
    wezterm.on(event, function(win, pane)
        local actions_ = actions

        if pane:get_foreground_process_name():find("n?vim") then
            actions_ = {
                wezterm.action.SendKey(leader),
                wezterm.action.SendKey({ key = key }),
            }
        end

        for _, action in ipairs(actions_) do
            win:perform_action(action, pane)
        end
    end)
end

register_event("GoToLeft", "h", { wezterm.action.ActivatePaneDirection("Left") })
register_event("GoToDown", "j", { wezterm.action.ActivatePaneDirection("Down") })
register_event("GoToUp", "k", { wezterm.action.ActivatePaneDirection("Up") })
register_event("GoToRight", "l", { wezterm.action.ActivatePaneDirection("Right") })
register_event("ToggleZoom", "z", { wezterm.action.TogglePaneZoomState })

config.disable_default_key_bindings = true
config.leader = { key = leader.key, mods = leader.mods, timeout_milliseconds = 1000 }
config.keys = {
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    { key = ";", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },

    { key = "s", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "c", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
    { key = "z", mods = "LEADER", action = wezterm.action.EmitEvent("ToggleZoom") },
    { key = "h", mods = "LEADER", action = wezterm.action.EmitEvent("GoToLeft") },
    { key = "j", mods = "LEADER", action = wezterm.action.EmitEvent("GoToDown") },
    { key = "k", mods = "LEADER", action = wezterm.action.EmitEvent("GoToUp") },
    { key = "l", mods = "LEADER", action = wezterm.action.EmitEvent("GoToRight") },

    { key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },

    { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
    { key = "]", mods = "LEADER", action = wezterm.action.PasteFrom("Clipboard") },

    { key = "q", mods = "LEADER", action = wezterm.action.QuickSelect },
}

return config
