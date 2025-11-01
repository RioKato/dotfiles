local wezterm = require("wezterm")

local function performSpawnShell(win, pane)
    local dimensions = pane:get_dimensions()

    local actions = {
        wezterm.action.SendString("python3 -c 'import pty; pty.spawn(\"/bin/sh\")'"),
        wezterm.action.SendKey({ key = "Return" }),
        wezterm.action.SendKey({ key = "z", mods = "CTRL" }),
        wezterm.action.SendString(
            string.format(
                "stty raw -echo; fg; reset xterm; export TERM=xterm; stty rows %d columns %d",
                dimensions.viewport_rows,
                dimensions.cols
            )
        ),
        wezterm.action.SendKey({ key = "Return" }),
    }

    for _, action in ipairs(actions) do
        win:perform_action(action, pane)
        wezterm.sleep_ms(100)
    end
end

local event = "SpawnShell"
wezterm.on(event, performSpawnShell)
return wezterm.action.EmitEvent(event)
