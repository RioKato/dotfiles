local function exec(cmd)
    return vim.fn.system({ "tmux", unpack(cmd) })
end

local function active()
    return vim.env.TMUX ~= nil
end

local function setup()
    if active() then
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                exec({ "set", "-p", "@vim", "1" })
            end,
        })

        vim.api.nvim_create_autocmd("VimLeave", {
            callback = function()
                exec({ "set", "-p", "@vim", "0" })
            end,
        })
    end
end

local zoom = {}

function zoom.toggle()
    exec({ "resizep", "-Z" })
end

function zoom.on()
    exec({ "if", "-F", "#{==:#{window_zoomed_flag},0}", "resizep -Z" })
end

function zoom.off()
    exec({ "if", "-F", "#{==:#{window_zoomed_flag},1}", "resizep -Z" })
end

local M = {
    setup = setup,
    active = active,
    zoom = zoom,
}

return M
