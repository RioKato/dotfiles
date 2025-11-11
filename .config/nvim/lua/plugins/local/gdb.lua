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

function MI.event(text, start)
    local parser = Parser.seq(Parser.regex("^[=*^&][^,]+"), Parser.try(Parser.seq(Parser.str(","), MI.inner)))
    local ok, next, result = parser(text, start)

    if ok then
        result = {
            event = result[1],
            info = result[2] and result[2][2] or {},
        }
    end

    return ok, next, result
end

function MI.msg(text, start)
    local parser = Parser.seq(Parser.str("~"), MI.str)
    local ok, next, result = parser(text, start)

    if ok then
        result = { msg = result[2] }
    end

    return ok, next, result
end

function MI.done(text, start)
    local parser = Parser.str("(gdb)")
    local ok, next, result = parser(text, start)

    if ok then
        result = { done = result }
    end

    return ok, next, result
end

MI.begin = Parser.br(MI.done, MI.event, MI.msg)

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
    local self = { listener = {} }
    setmetatable(self, { __index = Gdb })
    return self
end

function Gdb:open(cmd)
    local buf = ""

    self.jobid = vim.fn.jobstart(cmd, {
        on_stdout = function(_, lines, _)
            if #lines ~= 0 then
                lines[1] = buf .. lines[1]
                buf = table.remove(lines)

                vim.iter(lines):each(function(line)
                    local ok, result = MI.parse(line)

                    if not ok then
                        result = {}
                    end

                    result.raw = line

                    local event = result.event or (result.msg and "msg") or (result.done and "done") or ""

                    vim.iter(self.listener[event] or {}):each(function(callback)
                        callback(result, event)
                    end)
                end)
            end
        end,
    })
end

function Gdb:send(cmd)
    if self.jobid then
        vim.fn.chansend(self.jobid, cmd .. "\n")
    end
end

function Gdb:close()
    if self.jobid then
        vim.fn.jobstop(self.jobid)
        self.jobid = nil
    end
end

function Gdb:on(event, callback)
    if not self.listener[event] then
        self.listener[event] = {}
    end

    table.insert(self.listener[event], callback)
end

function Gdb:run()
    self:send("-exec-run")
end

function Gdb:step()
    self:send("-exec-step")
end

function Gdb:next()
    self:send("-exec-next")
end

function Gdb:finish()
    self:send("-exec-finish")
end

function Gdb:go(at)
    self:send(string.format("-exec-until %s", at))
end

function Gdb:continue()
    self:send("-exec-continue")
end

function Gdb:interrupt()
    self:send("-exec-interrupt")
end

function Gdb:prompt()
    local bufid = vim.api.nvim_create_buf(true, true)
    vim.bo[bufid].buftype = "prompt"

    vim.fn.prompt_setprompt(bufid, "")

    local last = ""

    vim.fn.prompt_setcallback(bufid, function(line)
        if line == "" then
            line = last
        else
            last = line
        end

        self:send(line)
    end)

    self:on("^error", function(data)
        local lines = vim.split(data.info.msg, "\n")
        vim.api.nvim_buf_set_text(bufid, -1, -1, -1, -1, lines)
    end)

    self:on("msg", function(data)
        local lines = vim.split(data.msg, "\n")
        vim.api.nvim_buf_set_text(bufid, -1, -1, -1, -1, lines)
    end)

    self:on("done", function()
        local sep = string.rep("─", 20)
        local lines = {}

        if vim.api.nvim_buf_get_lines(bufid, -2, -1, true)[1] ~= "" then
            lines = { "", sep, "" }
        else
            lines = { sep, "" }
        end

        vim.api.nvim_buf_set_text(bufid, -1, -1, -1, -1, lines)
    end)

    return bufid
end

function Gdb:breakpoints()
    self:on("^done", function(data)
        if data.bkpt then
            print(vim.inspect(data))
        end
    end)

    self:on("=breakpoint-created", function(data)
        print(vim.inspect(data))
    end)

    self:on("=breakpoint-deleted", function(data)
        print(vim.inspect(data))
    end)

    self:on("=breakpoint-modified", function(data)
        print(vim.inspect(data))
    end)
end

---------------------------------------------------------------------------------------------------
local function test()
    local gdb = Gdb.new()
    local bufid = gdb:prompt()
    gdb:breakpoints()

    gdb:open({ "gdb", "-i=mi" })
end

test()
