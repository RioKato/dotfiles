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

local function pass(name, opts)
    assert(opts.mods == "LEADER")
    local event = string.format("KEY_%s_%s", opts.mods, opts.key)

    wezterm.on(event, function(win, pane)
        local actions = { opts.action }

        if pane:get_foreground_process_name():find(name) then
            actions = {
                wezterm.action.SendKey({ key = config.leader.key, mods = config.leader.mods }),
                wezterm.action.SendKey({ key = opts.key }),
            }
        end

        for _, action in ipairs(actions) do
            win:perform_action(action, pane)
        end
    end)

    return { key = opts.key, mods = opts.mods, action = wezterm.action.EmitEvent(event) }
end

config.disable_default_key_bindings = true
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    { key = ";", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },

    { key = "s", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "c", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
    pass("nvim", { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState }),
    pass("nvim", { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") }),
    pass("nvim", { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") }),
    pass("nvim", { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") }),
    pass("nvim", { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") }),

    { key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },

    { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
    { key = "]", mods = "LEADER", action = wezterm.action.PasteFrom("Clipboard") },

    { key = "q", mods = "LEADER", action = wezterm.action.QuickSelect },
}

return config
