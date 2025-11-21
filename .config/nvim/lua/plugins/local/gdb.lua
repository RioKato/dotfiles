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

        local boolkey = {
            "enabled",
        }

        if vim.tbl_contains(intkey, data[1]) then
            data[2] = tonumber(data[2])
        elseif vim.tbl_contains(boolkey, data[1]) then
            local map = { y = true, n = false }
            data[2] = map[data[2]]
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
    local self = { listener = {}, ctx = {} }
    setmetatable(self, { __index = Gdb })
    return self
end

function Gdb:open(cmd)
    if not self.job then
        local buf = ""

        self.job = vim.system(cmd, {
            text = true,
            stdin = true,
            stdout = function(_, text)
                if text then
                    local lines = vim.split(buf .. text, "\n")
                    assert(#lines > 0)
                    buf = table.remove(lines)

                    vim.iter(lines):each(function(line)
                        local result = MI.parse(line) or {}
                        result.text = line
                        local event = result[1]

                        vim.iter(self.listener[event] or {}):each(function(callback)
                            vim.schedule(function()
                                callback(result, event)
                            end)
                        end)
                    end)
                end
            end,
            stderr = function(_, text)
                vim.schedule(function()
                    vim.notify(text)
                end)
            end,
        }, function()
            self.job = nil
        end)
    end
end

function Gdb:send(cmd)
    if self.job then
        self.job:write(cmd .. "\n")
    end
end

function Gdb:kill(name)
    if self.job then
        self.job:kill(name)
    end
end

function Gdb:close()
    self:kill("sigterm")
    self.ctx = {}
end

function Gdb:on(events, callback)
    vim.iter(events):each(function(event)
        if not self.listener[event] then
            self.listener[event] = {}
        end

        table.insert(self.listener[event], callback)
    end)
end

function Gdb:interrupt()
    self:kill("sigint")
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
    self:on({ "~" }, function(data)
        local msg = assert(data[2])

        if msg ~= "" then
            callback(msg)
        end
    end)

    self:on({ "^error" }, function(data)
        local msg = data.msg

        if msg and msg ~= "" then
            callback(msg .. "\n")
        end
    end)
end

function Gdb:onStop(callback)
    self:on({ "*stopped", "=thread-selected" }, function(data)
        self.ctx.stopped = nil
        local frame = data.frame

        if frame then
            local unknowns = { "??" }
            local func = not vim.tbl_contains(unknowns, frame.func) and frame.func or nil
            self.ctx.stopped = vim.deepcopy(frame)
            self.ctx.stopped.func = func
            callback()
        end
    end)

    self:on({ "*running" }, function()
        self.ctx.stopped = nil
    end)
end

function Gdb:onExit(callback)
    self:on({ "*stopped" }, function(data)
        local reason = data.reason

        if reason and vim.startswith(reason, "exited") then
            callback()
        end
    end)
end

function Gdb:onReceiveSignal(callback)
    self:on({ "*stopped" }, function(data)
        local signal = data["signal-name"]

        if signal then
            callback(signal)
        end
    end)
end

function Gdb:onReceiveInsns(callback)
    self:on({ "^done" }, function(data)
        local insns = data.asm_insns

        if insns then
            callback(insns)
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

    self:on({ "=breakpoint-created", "=breakpoint-modified" }, function(data, event)
        if data.bkpt then
            local bkpts = vim.iter(data.bkpt):fold({}, function(iv, bkpt)
                if bkpt.number then
                    iv[bkpt.number] = bkpt
                end
                return iv
            end)

            callback(assert(rename[event]), bkpts)
            self.ctx.bkpts = self.ctx.bkpts or {}

            vim.iter(pairs(bkpts)):each(function(id, bkpt)
                self.ctx.bkpts[id] = bkpt
            end)
        end
    end)

    self:on({ "=breakpoint-deleted" }, function(data, event)
        local id = data.id

        if id then
            callback(assert(rename[event]), id)
            self.ctx.bkpts = self.ctx.bkpts or {}
            self.ctx.bkpts[id] = nil
        end
    end)

    self:on({ "^done" }, function(data, event)
        if data.BreakpointTable and data.BreakpointTable.body and data.BreakpointTable.body.bkpt then
            local bkpts = vim.iter(data.BreakpointTable.body.bkpt):fold({}, function(iv, bkpt)
                if bkpt.number then
                    iv[bkpt.number] = bkpt
                end
                return iv
            end)

            callback(assert(rename[event]), bkpts)
            self.ctx.bkpts = bkpts
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
        vim.iter(pairs(range)):each(function(addr, row)
            self.range[addr] = { bufid, row }
        end)
    end

    function Cache:getPosition(addr)
        return unpack(self.range[addr] or {})
    end

    function Cache:getAddress(bufid, row)
        return vim.iter(pairs(self.range)):find(function(addr, pos)
            return pos[1] == bufid and pos[2] == row
        end)
    end

    local function load(cache, frame)
        local found = vim.iter({ frame.file, frame.fullname }):find(function(file)
            local stat = vim.uv.fs_stat(file)
            return stat and stat.type == "file"
        end)

        local bufid, row = nil, nil

        if found and frame.line then
            bufid = vim.fn.bufadd(found)
            vim.fn.bufload(bufid)
            vim.bo[bufid].buftype = "nofile"
            vim.bo[bufid].bufhidden = "hide"
            vim.bo[bufid].swapfile = false
            vim.bo[bufid].modifiable = false
            vim.bo[bufid].buflisted = false
            row = frame.line
        elseif cache and frame.addr then
            bufid, row = cache:getPosition(frame.addr)

            if bufid and not vim.api.nvim_buf_is_valid(bufid) then
                bufid, row = nil, nil
            end
        end

        return bufid, row
    end

    self:onStop(function()
        local bufid, row = load(self.ctx.cache, self.ctx.stopped)

        if bufid then
            window:set(bufid, assert(row))
        elseif self.ctx.stopped.func then
            self:disassembleFunction()
        else
            self:disassemblePC()
        end
    end)

    self:onReceiveInsns(function(insns)
        if self.ctx.stopped then
            local range = vim.iter(insns):enumerate():fold({}, function(iv, row, insn)
                if insn.address then
                    iv[insn.address] = row
                end
                return iv
            end)

            local row = range[self.ctx.stopped.addr]

            if row then
                local lines = vim.iter(insns)
                    :map(function(insn)
                        local addr = insn.address or -1
                        local func = insn["func-name"]
                        local offset = insn.offset
                        local label = func and offset and ("<%s+%04d>"):format(func, offset) or ""
                        local inst = insn.inst or ""
                        return ("0x%x%s │ %s"):format(addr, label, inst)
                    end)
                    :totable()

                local bufid = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(bufid, 0, -1, true, lines)
                vim.bo[bufid].modifiable = false
                vim.bo[bufid].filetype = "asm"
                window:set(bufid, row)

                self.ctx.cache = self.ctx.cache or Cache.new()
                self.ctx.cache:set(bufid, range)

                vim.iter(pairs(self.ctx.bkpts or {})):each(function(_, bkpt)
                    local row = range[bkpt.addr]

                    if row then
                        breakpoint:create(bufid, row, bkpt.enabled)
                    end
                end)
            end
        end
    end)

    self:onExit(function()
        self.ctx.cache = nil
        window:fallback()
    end)

    self:onChangeBkpts(function(event, data)
        local handler = {}

        function handler.create()
            vim.iter(pairs(data)):each(function(_, bkpt)
                local bufid, row = load(self.ctx.cache, bkpt)

                if bufid then
                    breakpoint:create(bufid, assert(row), bkpt.enabled)
                end
            end)
        end

        function handler.modify()
            vim.iter(pairs(data)):each(function(_, bkpt)
                local bufid, row = load(self.ctx.cache, bkpt)

                if bufid then
                    breakpoint:modify(bufid, assert(row), bkpt.enabled)
                end
            end)
        end

        function handler.delete()
            local bkpt = self.ctx.bkpts and self.ctx.bkpts[data]

            if bkpt then
                local bufid, row = load(self.ctx.cache, bkpt)

                if bufid then
                    breakpoint:delete(bufid, assert(row))
                end
            end
        end

        function handler.sync()
            breakpoint:clear()

            vim.iter(pairs(data)):each(function(_, bkpt)
                local bufid, row = load(self.ctx.cache, bkpt)

                if bufid then
                    breakpoint:create(bufid, assert(row), bkpt.enabled)
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

function Gdb:toggleBreakpoint()
    local winid = vim.api.nvim_get_current_win()
    local bufid = vim.api.nvim_win_get_buf(winid)
    local cursor = vim.api.nvim_win_get_cursor(winid)
    local path = vim.api.nvim_buf_get_name(bufid)
    local cmd = nil

    if path ~= "" then
        local base = vim.fs.basename(path)
        local found = vim.iter(pairs(self.ctx.bkpts or {})):find(function(_, bkpt)
            return bkpt.file == base and bkpt.line == cursor[1]
        end)
        cmd = found and ("delete %d"):format(found) or ("break %s:%d"):format(base, cursor[1])
    elseif self.ctx.cache then
        local addr = self.ctx.cache:getAddress(bufid, cursor[1])

        if addr then
            local found = vim.iter(pairs(self.ctx.bkpts or {})):find(function(_, bkpt)
                return bkpt.addr == addr
            end)
            cmd = found and ("delete %d"):format(found) or ("break *0x%x"):format(addr)
        end
    end

    if cmd then
        self:send(cmd)
    end
end

function Gdb:toggleEnableBreakpoint()
    local bkpts = vim.iter(pairs(self.ctx.bkpts or {}))
        :map(function(_, bkpt)
            return bkpt
        end)
        :totable()

    vim.ui.select(bkpts, {
        format_item = function(item)
            local enabled = nil

            if item.enabled ~= nil then
                enabled = item.enabled and "E" or "D"
            else
                enabled = " "
            end

            local addr = item.addr or 0
            local location = item.file and item.line and ("%s %d"):format(item.file, item.line) or ""
            return ("%s 0x%x │ %s"):format(enabled, addr, location)
        end,
    }, function(item)
        if item and item.enabled ~= nil then
            self:send(("%s %d"):format(item.enabled and "disable" or "enable", item.number))
        end
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
                return not value.executable or vim.fn.executable(value.executable) == 1
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
                else
                    self:GdbClose()
                end
            end)
        elseif #template == 1 then
            local item = template[1]
            self.gdb:open(item[2].command)
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
        if vim.api.nvim_win_is_valid(self.winid) and #vim.api.nvim_list_wins() ~= 1 then
            vim.api.nvim_win_close(self.winid, true)
        end

        self.winid = nil
    end
end

function Ui:GdbInterrupt()
    if self.gdb then
        self.gdb:interrupt()
    end
end

function Ui:GdbToggleBreakpoint()
    if self.gdb then
        self.gdb:toggleBreakpoint()
    end
end

function Ui:GdbToggleEnableBreakpoint()
    if self.gdb then
        self.gdb:toggleEnableBreakpoint()
    end
end

---------------------------------------------------------------------------------------------------
local M = {
    Mi = Mi,
    Gdb = Gdb,
    Window = Window,
    Breakpoint = Breakpoint,
    Ui = Ui,
}

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
        split = "right",
        win = -1,
        style = "minimal",
    },
    notification = true,
    keymap = true,
}

function M.setup(opts)
    opts = vim.tbl_deep_extend("force", default, opts or {})
    Ui.setup()

    local ui = Ui.new(opts)

    local items = {
        { "GdbOpen", "<leader>do" },
        { "GdbClose", "<leader>dO" },
        { "GdbInterrupt", "<leader>di" },
        { "GdbToggleBreakpoint", "<leader>db" },
        { "GdbToggleEnableBreakpoint", "<leader>dB" },
    }

    vim.iter(items):each(function(item)
        vim.api.nvim_create_user_command(item[1], function()
            ui[item[1]](ui)
        end, {})

        if opts.keymap then
            vim.keymap.set("n", item[2], ("<cmd>%s<cr>"):format(item[1]))
        end
    end)
end

return M
