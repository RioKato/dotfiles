local Proc = {}

function Proc:new(builder)
    local obj = {}
    setmetatable(obj, { __index = self })

    local buffer = ""

    obj.jobid = vim.fn.jobstart(builder.command, {
        on_stdout = function(_, lines, _)
            if #lines ~= 0 then
                lines[1] = buffer .. lines[1]
                buffer = table.remove(lines)

                vim.iter(lines):each(function(line)
                    vim.iter(builder.handlers):find(function(event, callback)
                        if line:sub(1, #event) == event then
                            return callback(obj, line)
                        end
                    end)
                end)
            end
        end,
    })

    return obj
end

function Proc:send(command)
    vim.fn.chansend(self.jobid, command)
end

local Builder = {}

function Builder:new(command)
    local obj = {
        command = command,
        handlers = {},
    }

    setmetatable(obj, { __index = self })
    return obj
end

function Builder:on(event, callback)
    self.handlers[event] = callback
end

function Builder:build()
    return Proc:new(self)
end

function Builder:default(command, window)
    local builder = self:new(command)

    local events = {
        ["*stopped"] = function(proc, message)
            window:handleCursor(proc, message)
        end,

        ["*running"] = function(proc, message)
            window:handleCursor(proc, message)
        end,

        ["=thread-selected"] = function(proc, message)
            window:handleCursor(proc, message)
        end,

        ["^done,bkpt="] = function(proc, message)
            window:handleNewBreakpoint(proc, message)
        end,

        ["=breakpoint-created,"] = function(proc, message)
            window:handleNewBreakpoint(proc, message)
        end,

        ["=breakpoint-modified,"] = function(proc, message)
            window:handleNewBreakpoint(proc, message)
        end,

        ["=breakpoint-deleted,"] = function(proc, message)
            window:handleBreakpointDelete(proc, message)
        end,

        ["=thread-group-started"] = function(proc, message)
            window:handleProgramRun(proc, message)
        end,

        ["^error,msg="] = function(proc, message)
            window:handleError()
        end,

        ['&"disassemble'] = function(proc, message)
            window:handleDisassemble()
        end,

        ["^done,variables="] = function(proc, message)
            window:handleVariables(proc, message)
        end,

        ["~"] = function(proc, message)
            message = message:match('^~"(.*)"$')

            if message then
                message = message:gsub("\\n", "\n")
                message = message:gsub('\\"', '"')
                return window:handleOutput(proc, message)
            end
        end,
    }

    vim.iter(events):each(function(event, callback)
        builder:on(event, callback)
    end)

    return builder
end

local Window = {}

function Window:new()
    local obj = {}
    setmetatable(obj, { __index = self })
    return obj
end

function Window:handleOutput(proc, message)
    print(message)
end

local recipes = {
    gdb = {
        command = { "gdb", "-i=mi" },
    },
}

local builder = Builder:default(recipes.gdb.command, Window:new())
local proc = builder:build()
