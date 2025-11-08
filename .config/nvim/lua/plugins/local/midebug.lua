local Proc = {}

function Proc:new(builder)
    local obj = {}
    setmetatable(obj, { __index = self })

    local buffer = ""

    obj.job = vim.fn.jobstart(builder.command, {
        on_stdout = function(_, lines, _)
            if #lines ~= 0 then
                lines[1] = buffer .. lines[1]
                buffer = table.remove(lines)

                vim.iter(lines):each(function(line)
                    builder:handle(line)
                end)
            end
        end,
    })

    return obj
end

function Proc:send(command)
    vim.fn.chansend(self.job, command)
end

function Proc:stop()
    vim.fn.jobstop(self.job)
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

function Builder:handle(message)
    vim.iter(self.handlers):find(function(event, callback)
        if message:sub(1, #event) == event then
            return callback(obj, message)
        end
    end)
end

function Builder:build()
    return Proc:new(self)
end

function Builder:default(command, window)
    local builder = self:new(command)

    local events = {
        ["*stopped"] = function(proc, message)
            return window:handleCursor(proc, message)
        end,

        ["*running"] = function(proc, message)
            return window:handleCursor(proc, message)
        end,

        ["=thread-selected"] = function(proc, message)
            return window:handleCursor(proc, message)
        end,

        ["^done,bkpt="] = function(proc, message)
            return window:handleBreakpoint(proc, message)
        end,

        ["=breakpoint-created,"] = function(proc, message)
            return window:handleBreakpoint(proc, message)
        end,

        ["=breakpoint-modified,"] = function(proc, message)
            return window:handleBreakpoint(proc, message)
        end,

        ["=breakpoint-deleted,"] = function(proc, message)
            return window:handleBreakpoint(proc, message)
        end,

        ["=thread-group-started"] = function(proc, message)
            return window:handleProgramRun(proc, message)
        end,

        ["^error,msg="] = function(proc, message)
            return window:handleError()
        end,

        ['&"disassemble'] = function(proc, message)
            return window:handleDisassemble()
        end,

        ["^done,variables="] = function(proc, message)
            return window:handleVariables(proc, message)
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

function Window:handleCursor(proc, message) end

function Window:handleBreakpoint(proc, message) end

function Window:handleProgramRun(proc, message) end

function Window:handleError(proc, message) end

function Window:handleDisassemble(proc, message) end

function Window:handleVariables(proc, message) end

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
