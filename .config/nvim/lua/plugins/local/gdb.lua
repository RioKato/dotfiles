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
        begin = event + msg,
    })

    return function(text)
        return lpeg.match(mi, text)
    end
end

local MI = { parse = parser() }

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
                    local event = result.event or (result.msg and "#msg") or ""

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
        if not pcall(vim.fn.chansend, self.jobid, cmd .. "\n") then
            self.jobid = nil
        end
    end
end

function Gdb:close()
    if self.jobid then
        pcall(vim.fn.jobstop, self.jobid)
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
    self:send("-data-disassemble -a $pc -- 0")
end

function Gdb:onReceiveMessage(callback)
    self:on("^error", function(data)
        callback(data.msg or "")
    end)

    self:on("#msg", function(data)
        assert(data.msg)
        callback(data.msg)
    end)
end

function Gdb:onStop(callback)
    self:on("*stopped", function(data)
        local frame = data.frame

        if frame and frame.addr then
            local addr = frame.addr
            local files = {}
            table.insert(files, frame.file)
            table.insert(files, frame.fullname)
            local line = tonumber(frame.line)
            callback(addr, files, line)
        end
    end)
end

function Gdb:onChangeBreakpoint(callback)
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

function Gdb:prompt()
    local bufid = vim.api.nvim_create_buf(true, true)
    vim.bo[bufid].buftype = "prompt"

    vim.fn.prompt_setcallback(bufid, function(line)
        self:send(line)
    end)

    self:onReceiveMessage(function(msg)
        local lines = vim.split(msg, "\n")
        vim.bo[bufid].buftype = "nofile"
        vim.api.nvim_buf_set_lines(bufid, -2, -1, false, lines)
        vim.bo[bufid].buftype = "prompt"
    end)

    return bufid
end

function Gdb:code(winid)
    self:onStop(function(addr, files, line)
        local found = vim.iter(files):find(function(file)
            local stat = vim.uv.fs_stat(file)
            return stat and stat.type == "file"
        end)

        if found and line then
            local bufid = vim.fn.bufadd(found)
            vim.bo[bufid].modifiable = false
            vim.api.nvim_win_set_buf(winid, bufid)
            vim.api.nvim_win_set_cursor(winid, { line, 0 })
        end
    end)
end

---------------------------------------------------------------------------------------------------
function Gdb:previwer(winid)
    local bufid = vim.api.nvim_create_buf(true, true)
    vim.bo[bufid].modifiable = false
    vim.bo[bufid].filetype = "asm"
    local lastaddr = nil

    local function draw()
        if lastaddr then
            local lines = vim.api.nvim_buf_get_lines(bufid, 0, -1, true)
            local found = vim.iter(lines):enumerate():find(function(_, line)
                return vim.startswith(line, lastaddr)
            end)

            if found then
                vim.api.nvim_win_set_buf(winid, bufid)
                vim.api.nvim_win_set_cursor(winid, { found, 0 })
            end
        end
    end

    self:onStop(function(addr)
        lastaddr = addr
        draw()
    end)

    self:on("^done", function(data)
        local asm_insns = data.asm_insns

        if asm_insns then
            local lines = vim.iter(asm_insns)
                :map(function(insn)
                    return string.format("%s│ %s", insn.address, insn.inst)
                end)
                :totable()

            vim.bo[bufid].modifiable = true
            vim.api.nvim_buf_set_lines(bufid, 0, -1, true, lines)
            vim.bo[bufid].modifiable = false
            draw()
        end
    end)

    return bufid
end

---------------------------------------------------------------------------------------------------
local function test()
    local gdb = Gdb.new()
    gdb:prompt()
    gdb:code(0)
    -- Setup.previwer(gdb, 0)
    gdb:open({ "gdb", "-i=mi" })
end

test()
