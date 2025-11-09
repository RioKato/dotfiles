---------------------------------------------------------------------------------------------------
local Parser = {}

function Parser.andp(...)
    local args = { ... }

    return function(text, start)
        local i = start
        local seq = {}

        for _, parser in ipairs(args) do
            local ok, next, result = parser(text, i)

            if ok then
                i = next
                table.insert(seq, result)
            else
                return false
            end
        end

        return true, i, seq
    end
end

function Parser.orp(...)
    local args = { ... }

    return function(text, start)
        for _, parser in ipairs(args) do
            local ok, next, result = parser(text, start)

            if ok then
                return true, next, result
            end
        end

        return false
    end
end

function Parser.repp(parser)
    return function(text, start)
        local i = start
        local seq = {}

        repeat
            local ok, next, result = parser(text, i)

            if ok then
                i = next
                table.insert(seq, result)
            end
        until not ok

        return true, i, seq
    end
end

function Parser.tryp(parser)
    return function(text, start)
        local ok, next, result = parser(text, start)

        if ok then
            return true, next, result
        else
            return true, start, nil
        end
    end
end

function Parser.strp(str)
    return function(text, start)
        local next = start + #str

        if text:sub(start, next - 1) == str then
            return true, next, str
        else
            return false
        end
    end
end

function Parser.regexp(regex)
    return function(text, start)
        local i, j = text:find(regex, start)

        if i then
            return true, j + 1, text:sub(i, j)
        else
            return false
        end
    end
end

---------------------------------------------------------------------------------------------------
local MI = {}

function MI.strp(text, start)
    local parser = Parser.andp(
        Parser.strp('"'),
        Parser.repp(Parser.orp(Parser.regexp("^\\."), Parser.regexp('^[^"]'))),
        Parser.strp('"')
    )

    local ok, next, result = parser(text, start)

    if ok then
        local map = {
            ["\\n"] = "\n",
            ["\\t"] = "\t",
            ['\\"'] = '"',
        }

        result = vim.iter(result[2])
            :map(function(char)
                return map[char] or char
            end)
            :join("")
    end

    return ok, next, result
end

function MI.pairp(text, start)
    local parser = Parser.andp(Parser.regexp("^[^=]+"), Parser.strp("="), Parser.orp(MI.strp, MI.objp))
    local ok, next, result = parser(text, start)

    if ok then
        result = { result[1], result[3] }
    end

    return ok, next, result
end

function MI.objp(text, start)
    local parser = Parser.andp(Parser.strp("{"), MI.argsp, Parser.strp("}"))
    local ok, next, result = parser(text, start)

    if ok then
        result = result[2]
    end

    return ok, next, result
end

function MI.argsp(text, start)
    local parser = Parser.repp(Parser.andp(MI.pairp, Parser.tryp(Parser.strp(","))))
    local ok, next, result = parser(text, start)

    if ok then
        result = vim.iter(result)
            :map(function(pair)
                local key = pair[1][1]
                local value = pair[1][2]
                return { key, value }
            end)
            :fold({}, function(left, right)
                left[right[1]] = right[2]
                return left
            end)
    end

    return ok, next, result
end

function MI.cmdp(text, start)
    local parser = Parser.andp(Parser.regexp("^[=*^&][^,]+"), Parser.tryp(Parser.andp(Parser.strp(","), MI.argsp)))
    local ok, next, result = parser(text, start)

    if ok then
        result = { command = { result[1], result[2] and result[2][2] or {} } }
    end

    return ok, next, result
end

function MI.msgp(text, start)
    local parser = Parser.andp(Parser.strp("~"), MI.strp)
    local ok, next, result = parser(text, start)

    if ok then
        result = { message = result[2] }
    end

    return ok, next, result
end

function MI.ignorep(text, start)
    local parser = Parser.strp("(gdb) ")
    local ok, next, result = parser(text, start)

    if ok then
        result = { ignore = result }
    end

    return ok, next, result
end

MI.beginp = Parser.orp(MI.msgp, MI.ignorep, MI.cmdp)

function MI.parse(text)
    local ok, next, result = MI.beginp(text, 1)

    if ok then
        result.rest = text:sub(next)
        return true, result
    else
        return false
    end
end

---------------------------------------------------------------------------------------------------
local Gdb = {}

function Gdb.new()
    local self = {}
    setmetatable(self, { __index = Gdb })
    return self
end

function Gdb:run(command, handler)
    local buffer = ""

    self.job = vim.fn.jobstart(command, {
        on_stdout = function(_, lines, _)
            if #lines ~= 0 then
                lines[1] = buffer .. lines[1]
                buffer = table.remove(lines)

                vim.iter(lines):each(function(line)
                    local ok, result = MI.parse(line)

                    if not ok then
                        result = {}
                    end

                    result.raw = line
                    handler:call(self, result)
                end)
            end
        end,
    })
end

function Gdb:send(command)
    if self.job then
        vim.fn.chansend(self.job, command)
    end
end

function Gdb:stop()
    if self.job then
        vim.fn.jobstop(self.job)
        self.job = nil
    end
end

---------------------------------------------------------------------------------------------------
local Handler = {}

function Handler.new()
    local self = { inner = {} }
    setmetatable(self, { __index = Handler })
    return self
end

function Handler:on(event, callback)
    self.inner[event] = callback
end

function Handler:handle(gdb, event, args)
    local callback = self.inner[event]

    if callback then
        callback(gdb, event, args)
        return true
    else
        return false
    end
end

function Handler:call(gdb, mi)
    local event = ""
    local args = nil

    if mi.command then
        event = mi.command[1]
        args = mi.command[2]
    end

    if mi.message then
        event = "MESSAGE"
        args = mi.message
    end

    if not self:handle(gdb, event, args) then
        self:handle(gdb, "UNHANDLED", mi)
    end
end

---------------------------------------------------------------------------------------------------

local function test()
    local handler = Handler.new()
    handler:on("UNHANDLED", function(gdb, event, args)
        print(event, vim.inspect(args))
    end)

    local gdb = Gdb.new()
    gdb:run({ "gdb", "-i=mi" }, handler)
end

test()
