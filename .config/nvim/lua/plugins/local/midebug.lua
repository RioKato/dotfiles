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
                    builder:handle(obj, line)
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
    table.insert(self.handlers, {
        event = event,
        callback = callback,
    })
end

function Builder:handle(proc, message)
    vim.iter(self.handlers):find(function(handler)
        if message:sub(1, #handler.event) == handler.event then
            return handler.callback(proc, message)
        end
    end)
end

function Builder:build()
    return Proc:new(self)
end

function Builder:default(command, window)
    local builder = self:new(command)

    local events = {
        ['*stopped,reason="exited-normally"'] = function(proc, message)
            return window:onExit(proc, message)
        end,

        ["*stopped"] = function(proc, message)
            return window:onStop(proc, message)
        end,

        ["*running"] = function(proc, message)
            return window:onRun(proc, message)
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
            return window:handleOutput(proc, message)
        end,
    }

    vim.iter(events):each(function(event, callback)
        builder:on(event, callback)
    end)

    return builder
end

local Parser = {}

function Parser.parseStr(text, start)
    local pos = start

    while true do
        pos = string.find(text, '"', pos + 1, true)

        if pos then
            local ok, inner = pcall(vim.json.decode, text:sub(start, pos))

            if ok then
                return inner
            end
        else
            break
        end
    end
end

function Parser.getValue(text, key, start)
    local ok, tail = string.find(text, string.format('%s="', key), start, true)

    if ok then
        return Parser.parseStr(text, tail)
    end
end

local Window = {}

function Window:new()
    local obj = {}
    setmetatable(obj, { __index = self })
    return obj
end

function Window:onExit(proc, message)
    local fullname = Parser.getValue(message, "fullname")

    local line = Parser.getValue(message, "line")
    line = line and tonumber(line)

    local addr = Parser.getValue(message, "addr")
    addr = addr and tonumber(line)
end

function Window:onStop(proc, message) end

function Window:onRun(proc, message) end

function Window:handleCursor(proc, message) end

function Window:handleBreakpoint(proc, message) end

function Window:handleProgramRun(proc, message) end

function Window:handleError(proc, message) end

function Window:handleDisassemble(proc, message) end

function Window:handleVariables(proc, message) end

function Window:handleOutput(proc, message) end

local recipes = {
    gdb = {
        command = { "gdb", "-i=mi" },
    },
}

local builder = Builder:default(recipes.gdb.command, Window:new())
local proc = builder:build()
