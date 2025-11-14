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

    local function toMsg(str)
        return { msg = str }
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
        msg = (lpeg.P("~") * str) / toMsg,
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

function Gdb:open(cmd, ctx)
    if not self.jobid then
        ctx = ctx or {}
        local buf = ""

        self.jobid = vim.fn.jobstart(cmd, {
            on_stdout = function(_, lines, _)
                assert(#lines > 0)
                lines[1] = buf .. lines[1]
                buf = table.remove(lines)

                vim.iter(lines):each(function(line)
                    local result = MI.parse(line) or {}
                    result.line = line
                    local event = result.event or (result.msg and "#msg") or ""

                    vim.iter(self.listener[event] or {}):each(function(callback)
                        callback(ctx, result, event)
                    end)
                end)
            end,
            on_stderr = function(_, lines, _)
                local text = vim.iter(lines):join("")

                if text ~= "" then
                    vim.notify(text)
                end
            end,
            on_exit = function()
                self.jobid = nil
            end,
        })
    end
end

function Gdb:send(cmd)
    if self.jobid then
        vim.fn.chansend(self.jobid, cmd .. "\n")
    end
end

function Gdb:close()
    if self.jobid then
        vim.fn.jobstop(self.jobid)
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
    self:on("^error", function(_, data)
        callback(data.msg or "")
    end)

    self:on("#msg", function(_, data)
        assert(data.msg)
        callback(data.msg)
    end)
end

function Gdb:onStop(callback)
    self:on("*stopped", function(ctx, data)
        local frame = data.frame

        if frame and frame.addr then
            local addr = tonumber(frame.addr)

            if addr then
                local files = {}
                table.insert(files, frame.file)
                table.insert(files, frame.fullname)
                local row = tonumber(frame.line)
                row = row and row > 0 and row - 1 or nil

                ctx.stop = {
                    addr = addr,
                    files = files,
                    row = row,
                }

                callback(ctx)
            end
        end
    end)
end

function Gdb:onChangeBreakpoint(callback)
    self:on("=breakpoint-created", function(ctx, data)
        local bkpt = data.bkpt

        if bkpt and bkpt.number then
            ctx.bkpts = ctx.bkpts or {}
            ctx.bkpts[bkpt.number] = bkpt
            callback(ctx)
        end
    end)

    self:on("=breakpoint-deleted", function(ctx, data)
        if data.id then
            ctx.bkpts = ctx.bkpts or {}
            ctx.bkpts[data.id] = nil
            callback(ctx)
        end
    end)

    self:on("=breakpoint-modified", function(ctx, data)
        local bkpt = data.bkpt

        if bkpt and bkpt.number then
            ctx.bkpts = ctx.bkpts or {}
            ctx.bkpts[bkpt.number] = bkpt
            callback(ctx)
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

function Gdb:code(display)
    self:onStop(function(ctx)
        local stop = ctx.stop
        local found = vim.iter(stop.files):find(function(file)
            local stat = vim.uv.fs_stat(file)
            return stat and stat.type == "file"
        end)

        if found and stop.row then
            local bufid = vim.fn.bufadd(found)
            vim.fn.bufload(bufid)
            vim.bo[bufid].modifiable = false
            display(bufid, stop.row)
        end
    end)
end

local function window(winid, nsid, hl)
    return function(bufid, row)
        vim.api.nvim_buf_clear_namespace(bufid, nsid, 0, -1)
        vim.api.nvim_buf_set_extmark(bufid, nsid, row, 0, {
            end_line = row + 1,
            hl_eol = true,
            hl_group = hl,
        })
        vim.api.nvim_win_set_buf(winid, bufid)
        vim.api.nvim_win_set_cursor(winid, { row + 1, 0 })
    end
end

---------------------------------------------------------------------------------------------------
function Gdb:asm(display)
    local bufid = vim.api.nvim_create_buf(true, true)
    vim.bo[bufid].modifiable = false
    vim.bo[bufid].filetype = "asm"

    self:on("^done", function(ctx, data)
        local stop = ctx.stop
        local asm_insns = data.asm_insns

        if asm_insns and stop then
            local row = vim.iter(asm_insns):enumerate():find(function(_, insn)
                return tonumber(insn.address) == stop.addr
            end)
            row = row and row - 1

            if row then
                local lines = vim.iter(asm_insns)
                    :map(function(insn)
                        return string.format("%s│ %s", insn.address, insn.inst)
                    end)
                    :totable()

                vim.bo[bufid].modifiable = true
                vim.api.nvim_buf_set_lines(bufid, 0, -1, true, lines)
                vim.bo[bufid].modifiable = false
                display(bufid, row)
            end
        end
    end)

    return bufid
end

---------------------------------------------------------------------------------------------------
local function test()
    local gdb = Gdb.new()
    gdb:prompt()
    local nsid = vim.api.nvim_create_namespace("MyLineHighlightsNS")
    vim.api.nvim_set_hl(0, "MyCustomLineHighlight", { bg = "#501010", force = true })
    gdb:code(window(0, nsid, "MyCustomLineHighlight"))
    gdb:asm(window(0, nsid, "MyCustomLineHighlight"))
    gdb:open({ "gdb", "-i=mi" })
end

test()
