---------------------------------------------------------------------------------------------------
local function parser()
    local lpeg = vim.lpeg

    local function toStr(chars)
        local map = {
            ["\\n"] = "\n",
            ["\\t"] = "\t",
            ['\\"'] = '"',
        }

        return vim.iter(chars)
            :map(function(char)
                return map[char] or char
            end)
            :join("")
    end

    local function toDict(pairs)
        return vim.iter(pairs):fold({}, function(left, right)
            left[right[1]] = right[2]
            return left
        end)
    end

    local function toEvent(data)
        local event = data[1]
        local dict = toDict(data[2])
        dict.event = event
        return dict
    end

    local any = lpeg.P(1)
    local str = lpeg.V("str")
    local pair = lpeg.V("pair")
    local dict = lpeg.V("dict")
    local list = lpeg.V("list")
    local obj = lpeg.V("obj")
    local event = lpeg.V("event")
    local msg = lpeg.V("msg")
    local done = lpeg.V("done")
    local begin = lpeg.V("begin")

    local mi = lpeg.P({
        begin,
        str = lpeg.Ct(lpeg.P('"') * lpeg.C(lpeg.P("\\") * any + (any - lpeg.P('"'))) ^ 0 * lpeg.P('"')) / toStr,
        pair = lpeg.Ct(lpeg.C((any - lpeg.P("=")) ^ 1) * lpeg.P("=") * obj),
        dict = lpeg.Ct(lpeg.P("{") * (lpeg.P("}") + pair * (lpeg.P(",") * pair) ^ 0 * lpeg.P("}"))) / toDict,
        list = lpeg.Ct(lpeg.P("[") * (lpeg.P("]") + obj * (lpeg.P(",") * obj) ^ 0 * lpeg.P("]"))),
        obj = str + dict + list,
        event = lpeg.Ct(lpeg.C(lpeg.S("=*^") * (any - lpeg.P(",")) ^ 0) * lpeg.Ct((lpeg.P(",") * pair) ^ 0)) / toEvent,
        msg = (lpeg.P("~") * str) / function(msg)
            return { msg = msg }
        end,
        done = lpeg.P("(gdb)") / function()
            return { done = true }
        end,
        begin = event + msg + done,
    })

    return function(text)
        return lpeg.match(mi, text)
    end
end

local MI = {}
MI.parse = parser()

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
                    local result = MI.parse(line) or {}
                    result.raw = line

                    local event = result.event or (result.msg and "#msg") or (result.done and "#done") or ""

                    print(vim.inspect(result))
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

function Gdb:disassemble()
    self:send("-data-disassemble -a $pc")
end

function Gdb:prompt(callback)
    self:on("^error", function(data)
        callback(data.msg)
    end)

    self:on("#msg", function(data)
        callback(data.msg)
    end)

    self:on("#done", function()
        callback(nil)
    end)
end

function Gdb:src(callback)
    self:on("*stopped", function(data)
        local frame = data.frame

        if frame then
            local found = vim.iter({ frame.file, frame.fullname }):find(function(file)
                local stat = vim.uv.fs_stat(file)

                if stat then
                    return stat.type == "file"
                end
            end)

            if found and frame.line then
                -- local bufid = vim.fn.bufadd(found)
                -- vim.bo[bufid].modifiable = false
                callback(found, frame.line, frame.args or {})
            end
        end
    end)
end

function Gdb:disass(callback)
    self:on("*stopped", function(data)
        local frame = data.frame

        if frame and frame.addr then
            callback(frame.addr)
        end
    end)
end

function Gdb:bkpt(callback)
    local bkpts = {}

    self:on("=breakpoint-created", function(data)
        local bkpt = data.bkpt

        if bkpt and bkpt.number then
            bkpts[bkpt.number] = bkpt
            callback(bkpts)
        end
    end)

    self:on("=breakpoint-deleted", function(data)
        if data.id then
            bkpts[data.id] = nil
            callback(bkpts)
        end
    end)

    self:on("=breakpoint-modified", function(data)
        local bkpt = data.bkpt

        if bkpt and bkpt.number then
            bkpts[bkpt.number] = bkpt
            callback(bkpts)
        end
    end)
end

---------------------------------------------------------------------------------------------------
local Setup = {}

function Setup.simple(gdb)
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

        gdb:send(line)
    end)

    gdb:prompt(function(msg)
        local lines = {}

        if msg == nil then
            local sep = string.rep("─", 20)

            if vim.api.nvim_buf_get_lines(bufid, -2, -1, true)[1] ~= "" then
                lines = { "", sep, "" }
            else
                lines = { sep, "" }
            end
        else
            lines = vim.split(msg, "\n")
        end

        vim.api.nvim_buf_set_text(bufid, -1, -1, -1, -1, lines)
    end)
end

---------------------------------------------------------------------------------------------------
local function test()
    local gdb = Gdb.new()
    local bufid = Setup.simple(gdb)
    -- Setup.src(gdb)
    -- Setup.disass(gdb)
    -- Setup.bkpt(gdb)

    gdb:open({ "gdb", "-i=mi" })
end

test()
