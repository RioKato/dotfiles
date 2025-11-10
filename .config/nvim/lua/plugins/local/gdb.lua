---------------------------------------------------------------------------------------------------
local Parser = {}

function Parser.seq(...)
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

function Parser.br(...)
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

function Parser.rep(parser)
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

function Parser.try(parser)
    return function(text, start)
        local ok, next, result = parser(text, start)

        if ok then
            return true, next, result
        else
            return true, start, nil
        end
    end
end

function Parser.str(str)
    return function(text, start)
        local next = start + #str

        if text:sub(start, next - 1) == str then
            return true, next, str
        else
            return false
        end
    end
end

function Parser.regex(regex)
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

function MI.str(text, start)
    local parser =
        Parser.seq(Parser.str('"'), Parser.rep(Parser.br(Parser.regex("^\\."), Parser.regex('^[^"]'))), Parser.str('"'))
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

function MI.pair(text, start)
    local parser = Parser.seq(Parser.regex("^[^=]+"), Parser.str("="), Parser.br(MI.str, MI.dict))
    local ok, next, result = parser(text, start)

    if ok then
        result = { result[1], result[3] }
    end

    return ok, next, result
end

function MI.dict(text, start)
    local parser = Parser.seq(Parser.str("{"), MI.inner, Parser.str("}"))
    local ok, next, result = parser(text, start)

    if ok then
        result = result[2]
    end

    return ok, next, result
end

function MI.inner(text, start)
    local parser = Parser.rep(Parser.seq(MI.pair, Parser.try(Parser.str(","))))
    local ok, next, result = parser(text, start)

    if ok then
        result = vim.iter(result):fold({}, function(left, right)
            local key = right[1][1]
            local value = right[1][2]
            left[key] = value
            return left
        end)
    end

    return ok, next, result
end

function MI.cmd(text, start)
    local parser = Parser.seq(Parser.regex("^[=*^&][^,]+"), Parser.try(Parser.seq(Parser.str(","), MI.inner)))
    local ok, next, result = parser(text, start)

    if ok then
        result = {
            command = {
                event = result[1],
                info = result[2] and result[2][2] or {},
            },
        }
    end

    return ok, next, result
end

function MI.msg(text, start)
    local parser = Parser.seq(Parser.str("~"), MI.str)
    local ok, next, result = parser(text, start)

    if ok then
        result = { message = result[2] }
    end

    return ok, next, result
end

function MI.ignore(text, start)
    local parser = Parser.str("(gdb) ")
    local ok, next, result = parser(text, start)

    if ok then
        result = { ignore = result }
    end

    return ok, next, result
end

MI.begin = Parser.br(MI.ignore, MI.cmd, MI.msg)

function MI.parse(text)
    local ok, next, result = MI.begin(text, 1)

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

function Gdb:run(command, listener)
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
                    listener:listen(self, result)
                end)
            end
        end,
    })
end

function Gdb:send(command)
    if self.job then
        vim.fn.chansend(self.job, command .. "\n")
    end
end

function Gdb:stop()
    if self.job then
        vim.fn.jobstop(self.job)
        self.job = nil
    end
end

---------------------------------------------------------------------------------------------------
local Listener = {}

function Listener.new()
    local self = { callback = {} }
    setmetatable(self, { __index = Listener })
    return self
end

function Listener:on(event, callback)
    self.callback[event] = callback
end

function Listener:listen(gdb, mi)
    local event = ""
    local info = mi

    if mi.command then
        event = mi.command.event
        info = mi.command.info
    end

    if mi.message then
        event = "MESSAGE"
        info = mi.message
    end

    if mi.ignore then
        event = "IGNORE"
        info = mi.ignore
    end

    if not self.callback[event] then
        event = ""
        info = mi
    end

    local callback = self.callback[event]

    if callback then
        callback(gdb, info, event)
    end
end

---------------------------------------------------------------------------------------------------
local Prompt = {}

function Prompt.setup(listener)
    local buf = vim.api.nvim_create_buf(true, true)
    vim.bo[buf].buftype = "prompt"

    listener:on("MESSAGE", function(gdb, text)
        vim.api.nvim_buf_set_text(buf, -1, -1, -1, -1, vim.split(text, "\n"))
    end)

    return buf
end

---------------------------------------------------------------------------------------------------
local function test()
    local listener = Listener.new()
    local buf = Prompt.setup(listener)
    local gdb = Gdb.new()

    vim.fn.prompt_setcallback(buf, function(line)
        vim.notify(line)
        gdb:send(line)
    end)

    gdb:run({ "gdb", "-i=mi" }, listener)
end

test()
