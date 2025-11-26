local root = "plugins.local"

local init = {}

function init.hover()
    require(root .. ".hover").setup()
end

function init.wezterm()
    require(root .. ".wezterm").setup()
end

function init.gdb()
    require(root .. ".gdb").setup()

    local cmds = {
        GdbOpen = "<leader>do",
        GdbClose = "<leader>dc",
        GdbInterrupt = "<leader>di",
        GdbSyncBreakpoints = "<leader>ds",
        GdbToggleBreakpoint = "<leader>db",
        GdbToggleEnableBreakpoint = "<leader>dB",
        GdbPrintCWord = "<leader>dp",
    }

    vim.iter(cmds):each(function(cmd, key)
        vim.keymap.set("n", key, ("<cmd>%s<cr>"):format(cmd))
    end)
end

function init:all()
    self.hover()
    self.wezterm()
    self.gdb()
end

init:all()
