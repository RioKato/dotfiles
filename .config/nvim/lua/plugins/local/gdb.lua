---------------------------------------------------------------------------------------------------
local function parser()
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

    local function toPair(data)
        local intkey = {
            "addr",
            "line",
            "address",
            "offset",
            "number",
            "id",
        }

        if vim.tbl_contains(intkey, data[1]) then
            data[2] = tonumber(data[2])
        end

        data.pair = true
        return data
    end

    local function norm(data)
        local special = { "bkpt" }

        return vim.iter(data):fold({}, function(left, right)
            if right.pair then
                local key = right[1]
                local value = right[2]

                if vim.tbl_contains(special, key) then
                    left[key] = left[key] or {}
                    table.insert(left[key], value)
                else
                    left[key] = value
                end
            else
                table.insert(left, right)
            end

            return left
        end)
    end

    local lpeg = vim.lpeg
    local any = lpeg.P(1)
    local str = lpeg.V("str")
    local pair = lpeg.V("pair")
    local dict = lpeg.V("dict")
    local list = lpeg.V("list")
    local obj = lpeg.V("obj")
    local info = lpeg.V("info")
    local msg = lpeg.V("msg")
    local begin = lpeg.V("begin")

    local mi = lpeg.P({
        begin,
        str = lpeg.Ct(lpeg.P('"') * lpeg.C(lpeg.P("\\") * any + (any - lpeg.P('"'))) ^ 0 * lpeg.P('"')) / toStr,
        pair = lpeg.Ct(lpeg.C((any - lpeg.P("=")) ^ 1) * lpeg.P("=") * obj) / toPair,
        dict = lpeg.Ct(lpeg.P("{") * (lpeg.P("}") + (obj + pair) * (lpeg.P(",") * (obj + pair)) ^ 0 * lpeg.P("}"))) / norm,
        list = lpeg.Ct(lpeg.P("[") * (lpeg.P("]") + (obj + pair) * (lpeg.P(",") * (obj + pair)) ^ 0 * lpeg.P("]"))) / norm,
        obj = str + dict + list,
        info = lpeg.Ct(lpeg.C(lpeg.S("=*^") * (any - lpeg.P(",")) ^ 1) * (lpeg.P(",") * pair) ^ 0) / norm,
        msg = lpeg.Ct(lpeg.C(lpeg.P("~")) * str),
        begin = info + msg,
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
    if not self.jobid then
        local ctx = {}
        local buf = ""

        self.jobid = vim.fn.jobstart(cmd, {
            on_stdout = function(_, lines, _)
                assert(#lines > 0)
                lines[1] = buf .. lines[1]
                buf = table.remove(lines)

                vim.iter(lines):each(function(line)
                    local result = MI.parse(line) or {}
                    result.text = line
                    local event = result[1] or ""

                    vim.iter(self.listener[event] or {}):each(function(callback)
                        callback(ctx, result, event)
                    end)
                end)
            end,
            on_stderr = function(_, lines, _)
                local text = vim.iter(lines):join("\n")

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

function Gdb:on(events, callback)
    vim.iter(events):each(function(event)
        if not self.listener[event] then
            self.listener[event] = {}
        end

        table.insert(self.listener[event], callback)
    end)
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

function Gdb:disassembleFunction()
    self:send("-data-disassemble -a $pc -- 0")
end

function Gdb:disassemblePC()
    self:send("-data-disassemble -s $pc -e $pc+0x100 -- 0")
end

function Gdb:breakList()
    self:send("-break-list")
end

function Gdb:onReceiveMessage(callback)
    self:on({ "~" }, function(_, data)
        local msg = assert(data[2])

        if msg ~= "" then
            callback(msg)
        end
    end)

    self:on({ "^error" }, function(_, data)
        local msg = data.msg

        if msg and msg ~= "" then
            callback(msg .. "\n")
        end
    end)
end

function Gdb:onStop(callback)
    self:on({ "*stopped", "=thread-selected" }, function(ctx, data)
        ctx.stopped = nil
        local frame = data.frame

        if frame then
            local unknowns = { "??" }
            local func = not vim.tbl_contains(unknowns, frame.func) and frame.func or nil
            ctx.stopped = vim.deepcopy(frame)
            ctx.stopped.func = func
            callback(ctx)
        end
    end)

    self:on({ "*running" }, function(ctx)
        ctx.stopped = nil
    end)
end

function Gdb:onExit(callback)
    self:on({ "*stopped" }, function(ctx, data)
        local reason = data.reason

        if reason and vim.startswith(reason, "exited") then
            callback(ctx)
        end
    end)
end

function Gdb:onReceiveSignal(callback)
    self:on({ "*stopped" }, function(_, data)
        local signal = data["signal-name"]

        if signal then
            callback(signal)
        end
    end)
end

function Gdb:onReceiveInsns(callback)
    self:on({ "^done" }, function(ctx, data)
        local insns = data.asm_insns

        if insns then
            callback(ctx, insns)
        end
    end)
end

function Gdb:onChangeBkpts(callback)
    local rename = {
        ["=breakpoint-created"] = "create",
        ["=breakpoint-modified"] = "modify",
        ["=breakpoint-deleted"] = "delete",
        ["^done"] = "sync",
    }

    self:on({ "=breakpoint-created", "=breakpoint-modified" }, function(ctx, data, event)
        if data.bkpt then
            local bkpts = vim.iter(data.bkpt):fold({}, function(iv, bkpt)
                if bkpt.number then
                    iv[bkpt.number] = bkpt
                end
                return iv
            end)

            callback(ctx, bkpts, assert(rename[event]))
            ctx.bkpts = ctx.bkpts or {}

            vim.iter(pairs(bkpts)):each(function(id, bkpt)
                ctx.bkpts[id] = bkpt
            end)
        end
    end)

    self:on({ "=breakpoint-deleted" }, function(ctx, data, event)
        local id = data.id

        if id then
            callback(ctx, id, assert(rename[event]))
            ctx.bkpts = ctx.bkpts or {}
            ctx.bkpts[id] = nil
        end
    end)

    self:on({ "^done" }, function(ctx, data, event)
        if data.BreakpointTable and data.BreakpointTable.body and data.BreakpointTable.body.bkpt then
            local bkpts = vim.iter(data.BreakpointTable.body.bkpt):fold({}, function(iv, bkpt)
                if bkpt.number then
                    iv[bkpt.number] = bkpt
                end
                return iv
            end)

            callback(ctx, bkpts, assert(rename[event]))
            ctx.bkpts = bkpts
        end
    end)
end

function Gdb:prompt()
    local bufid = vim.api.nvim_create_buf(true, true)
    vim.bo[bufid].buftype = "prompt"
    local last = ""

    vim.fn.prompt_setcallback(bufid, function(line)
        last = line ~= "" and line or last
        self:send(last)
    end)

    self:onReceiveMessage(function(msg)
        local lines = vim.split(msg, "\n")
        vim.bo[bufid].buftype = "nofile"
        vim.api.nvim_buf_set_text(bufid, -1, -1, -1, -1, lines)
        vim.bo[bufid].buftype = "prompt"
    end)

    return bufid
end

function Gdb:code(window, breakpoint)
    local Cache = {}

    function Cache.new()
        local self = { range = {} }
        setmetatable(self, { __index = Cache })
        return self
    end

    function Cache:set(bufid, range)
        self.range[bufid] = range
    end

    function Cache:get(addr)
        vim.iter(pairs(self.range)):each(function(bufid)
            if not vim.api.nvim_buf_is_valid(bufid) then
                self.range[bufid] = nil
            end
        end)

        return vim.iter(pairs(self.range)):find(function(_, range)
            return range[addr]
        end)
    end

    local function load(ctx, frame)
        local found = vim.iter({ frame.file, frame.fullname }):find(function(file)
            local stat = vim.uv.fs_stat(file)
            return stat and stat.type == "file"
        end)

        if found and frame.line then
            local bufid = vim.fn.bufadd(found)
            vim.fn.bufload(bufid)
            vim.bo[bufid].buftype = "nofile"
            vim.bo[bufid].bufhidden = "hide"
            vim.bo[bufid].swapfile = false
            vim.bo[bufid].modifiable = false
            return bufid, frame.line
        elseif ctx.cache and frame.addr then
            local bufid, range = ctx.cache:get(frame.addr)
            line = bufid and assert(range[frame.addr])
            return bufid, line
        end
    end

    self:onStop(function(ctx)
        local stopped = assert(ctx.stopped)
        local bufid, row = load(ctx, stopped)

        if bufid then
            window:set(bufid, assert(row))
        elseif stopped.func then
            self:disassembleFunction()
        else
            self:disassemblePC()
        end
    end)

    self:onReceiveInsns(function(ctx, insns)
        local stopped = ctx.stopped

        if stopped then
            local range = vim.iter(insns):enumerate():fold({}, function(iv, row, insn)
                if insn.address then
                    iv[insn.address] = row
                end
                return iv
            end)

            local row = range[stopped.addr]

            if row then
                local lines = vim.iter(insns)
                    :map(function(insn)
                        local addr = insn.address or -1
                        local func = insn["func-name"]
                        local offset = insn.offset
                        local label = func and offset and ("<%s+0x%04x>"):format(func, offset) or ""
                        local inst = insn.inst or ""
                        return ("0x%016x%s │ %s"):format(addr, label, inst)
                    end)
                    :totable()

                local bufid = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(bufid, 0, -1, true, lines)
                vim.bo[bufid].modifiable = false
                vim.bo[bufid].filetype = "asm"
                window:set(bufid, row)

                ctx.cache = ctx.cache or Cache.new()
                ctx.cache:set(bufid, range)
            end
        end
    end)

    self:onExit(function(ctx)
        ctx.cache = nil
        window:fallback()
    end)

    self:onChangeBkpts(function(ctx, data, event)
        local toBool = { y = true, n = false }
        local handler = {}

        function handler.create()
            vim.iter(pairs(data)):each(function(_, bkpt)
                local bufid, row = load(ctx, bkpt)

                if bufid then
                    breakpoint:create(bufid, assert(row), toBool[bkpt.enabled])
                end
            end)
        end

        function handler.modify()
            vim.iter(pairs(data)):each(function(_, bkpt)
                local bufid, row = load(ctx, bkpt)

                if bufid then
                    breakpoint:modify(bufid, assert(row), toBool[bkpt.enabled])
                end
            end)
        end

        function handler.delete()
            local bkpt = ctx.bkpts and ctx.bkpts[data]

            if bkpt then
                local bufid, row = load(ctx, bkpt)

                if bufid then
                    breakpoint:delete(bufid, assert(row))
                end
            end
        end

        function handler.sync()
            breakpoint:clear()

            vim.iter(pairs(data)):each(function(_, bkpt)
                local bufid, row = load(ctx, bkpt)

                if bufid then
                    breakpoint:create(bufid, assert(row), toBool[bkpt.enabled])
                end
            end)
        end

        assert(handler[event])()
    end)
end

function Gdb:notify()
    self:onExit(function()
        vim.notify("exited")
    end)

    self:onReceiveSignal(function(signal)
        vim.notify(("%s received"):format(signal))
    end)
end

---------------------------------------------------------------------------------------------------
local Window = {
    sign = {
        id = 1,
        name = "DebugPC",
        group = "DebugPC",
    },
}

function Window.setup()
    vim.fn.sign_define(Window.sign.name, { linehl = Window.sign.name })
    vim.api.nvim_set_hl(0, Window.sign.name, { reverse = true })
end

function Window.new()
    local winid = vim.api.nvim_get_current_win()

    local self = {
        winid = winid,
        bufid = vim.api.nvim_win_get_buf(winid),
        cursor = vim.api.nvim_win_get_cursor(winid),
    }

    setmetatable(self, { __index = Window })
    return self
end

function Window:fallback()
    vim.fn.sign_unplace(self.sign.group, { id = self.sign.id })
    vim.api.nvim_win_set_buf(self.winid, self.bufid)
    vim.api.nvim_win_set_cursor(self.winid, self.cursor)
end

function Window:set(bufid, row)
    vim.fn.sign_unplace(self.sign.group, { id = self.sign.id })
    vim.fn.sign_place(self.sign.id, self.sign.group, self.sign.name, bufid, { lnum = row })
    vim.api.nvim_win_set_buf(self.winid, bufid)
    vim.api.nvim_win_set_cursor(self.winid, { row, 0 })
end

---------------------------------------------------------------------------------------------------
local Breakpoint = {
    sign = {
        name = {
            [true] = "BreakpointEnabled",
            [false] = "BreakpointDisabled",
        },
        group = "Breakpoint",
    },
}

function Breakpoint.setup()
    vim.fn.sign_define(Breakpoint.sign.name[true], { text = "E" })
    vim.fn.sign_define(Breakpoint.sign.name[false], { text = "D" })
end

function Breakpoint.new()
    local self = {}
    setmetatable(self, { __index = Breakpoint })
    return self
end

function Breakpoint:create(bufid, row, enabled)
    local name = self.sign.name[enabled or enabled == nil]
    vim.fn.sign_place(0, self.sign.group, name, bufid, { lnum = row })
end

function Breakpoint:modify(bufid, row, enabled)
    self:delete(bufid, row)
    self:create(bufid, row, enabled)
end

function Breakpoint:delete(bufid, row)
    local placed = vim.fn.sign_getplaced(bufid, { group = self.sign.group, lnum = row })
    local signs = assert(placed[1]).signs

    vim.iter(signs):each(function(sign)
        vim.fn.sign_unplace(self.sign.group, { id = sign.id })
    end)
end

function Breakpoint:clear()
    vim.fn.sign_unplace(self.sign.group)
end

---------------------------------------------------------------------------------------------------
local Ui = {}

function Ui.setup()
    Window.setup()
    Breakpoint.setup()
end

function Ui.new(opts)
    local self = { opts = opts }
    setmetatable(self, { __index = Ui })
    return self
end

function Ui:GdbOpen()
    if not self.gdb then
        self.gdb = Gdb.new()
        self.bufid = self.gdb:prompt()
        self.gdb:code(Window.new(), Breakpoint.new())

        if self.opts.notification then
            self.gdb:notify()
        end

        local template = vim.iter(self.opts.template)
            :filter(function(key, value)
                return vim.fn.executable(value.executable) == 1
            end)
            :totable()

        if #template > 1 then
            vim.ui.select(template, {
                format_item = function(item)
                    return item[1]
                end,
            }, function(item)
                if item then
                    self.gdb:open(item[2].command)
                end
            end)
        elseif #template == 1 then
            self.gdb:open(template[1][2].command)
        else
            vim.notify("template not found")
        end
    end

    if not self.winid or not vim.api.nvim_win_is_valid(self.winid) then
        self.winid = vim.api.nvim_open_win(self.bufid, false, self.opts.window)
    end
end

function Ui:GdbClose()
    if self.gdb then
        self.gdb:close()
        self.gdb = nil
    end

    if self.bufid then
        if vim.api.nvim_buf_is_valid(self.bufid) then
            vim.api.nvim_buf_delete(self.bufid, { force = true })
        end

        self.bufid = nil
    end

    if self.winid then
        if vim.api.nvim_win_is_valid(self.winid) then
            vim.api.nvim_win_close(self.winid, true)
        end

        self.winid = nil
    end
end

---------------------------------------------------------------------------------------------------
local M = {}

local default = {
    template = {
        gdb = {
            command = { "gdb", "-i=mi" },
            executable = "gdb",
        },

        rr = {
            command = { "rr", "replay", "-i=mi" },
            executable = "rr",
        },
    },
    window = {
        split = "below",
        win = -1,
        style = "minimal",
        height = 10,
    },
    notification = true,
}

function M.setup(opts)
    opts = vim.tbl_deep_extend("force", default, opts or {})
    Ui.setup()

    local ui = Ui.new(opts)

    vim.api.nvim_create_user_command("GdbOpen", function()
        ui:GdbOpen()
    end, {})

    vim.api.nvim_create_user_command("GdbClose", function()
        ui:GdbClose()
    end, {})
end

M.setup()
