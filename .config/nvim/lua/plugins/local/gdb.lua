---------------------------------------------------------------------------------------------------
local function parser()
    local bs = {
        ["\\n"] = "\n",
        ["\\t"] = "\t",
        ["\\e"] = string.char(0x1b),
        ['\\"'] = '"',
    }

    for i = 0, 255 do
        bs[("\\%03o"):format(i)] = string.char(i)
    end

    local function toChar(esc)
        return bs[esc] or esc
    end

    local function toStr(chars)
        return vim.iter(chars):join("")
    end

    local function toPair(data)
        local handler = {
            addr = tonumber,
            line = tonumber,
            address = tonumber,
            offset = tonumber,
            id = tonumber,
            number = function(data)
                local decimal = lpeg.C(lpeg.R("09") ^ 1) / tonumber
                local pattern = lpeg.Ct(decimal * (lpeg.P(".") * decimal) ^ -1)
                return lpeg.match(pattern, data)
            end,
            enabled = function(data)
                local yn = { y = true, n = false }
                return yn[data]
            end,
            func = function(data)
                local unknowns = { "??", "" }
                if not vim.tbl_contains(unknowns, data) then
                    return data
                end
            end,
            ["func-name"] = function(data)
                if data ~= "" then
                    return data
                end
            end,
            locations = function(data)
                return vim.iter(data):fold({}, function(left, right)
                    if right.number and right.number[2] then
                        left[right.number[2]] = right
                    end

                    return left
                end)
            end,
        }

        local key = data[1]
        local value = data[2]

        if handler[key] then
            data[2] = handler[key](value)
        end

        data.pair = true
        return data
    end

    local function toObj(data)
        local handler = {
            bkpt = function(left, right)
                left = left or {}

                if right.number then
                    left[right.number[1]] = right
                end

                return left
            end,
        }

        return vim.iter(data):fold({}, function(left, right)
            if right.pair then
                local key = right[1]
                local value = right[2]

                if handler[key] then
                    value = handler[key](left[key], value)
                end

                left[key] = value
            else
                table.insert(left, right)
            end

            return left
        end)
    end

    local lpeg = vim.lpeg
    local any = lpeg.P(1)
    local digit = lpeg.R("09")
    local esc = lpeg.V("esc")
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
        esc = lpeg.C(lpeg.P("\\") * (digit * digit * digit + any)) / toChar,
        str = lpeg.Ct(lpeg.P('"') * (esc + lpeg.C(any - lpeg.P('"'))) ^ 0 * lpeg.P('"')) / toStr,
        pair = lpeg.Ct(lpeg.C((any - lpeg.P("=")) ^ 1) * lpeg.P("=") * obj) / toPair,
        dict = lpeg.Ct(lpeg.P("{") * (lpeg.P("}") + (obj + pair) * (lpeg.P(",") * (obj + pair)) ^ 0 * lpeg.P("}"))) / toObj,
        list = lpeg.Ct(lpeg.P("[") * (lpeg.P("]") + (obj + pair) * (lpeg.P(",") * (obj + pair)) ^ 0 * lpeg.P("]"))) / toObj,
        obj = str + dict + list,
        info = lpeg.Ct(lpeg.C(lpeg.S("=*^") * (any - lpeg.P(",")) ^ 1) * (lpeg.P(",") * pair) ^ 0) / toObj,
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
    local self = {
        initializer = {},
        listener = {},
    }
    setmetatable(self, { __index = Gdb })
    return self
end

function Gdb:open(cmd, opts)
    if not self.job then
        self.ctx = {}

        vim.iter(self.initializer):each(function(callback)
            callback(self.ctx)
        end)

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
            stderr = opts.stderr,
            cwd = opts.cwd,
            env = opts.env,
            detach = opts.detach,
        }, function()
            self.job = nil
            self.ctx = nil

            if opts.exit then
                opts.exit()
            end
        end)
    end
end

function Gdb:kill(name)
    if self.job then
        self.job:kill(name)
    end
end

local sigfuns = {
    close = "sigterm",
    interrupt = "sigint",
}

vim.iter(sigfuns):each(function(name, sig)
    Gdb[name] = function(self)
        self:kill(sig)
    end
end)

function Gdb:send(cmd)
    if self.job then
        self.job:write(cmd .. "\n")
    end
end

local mifuns = {
    disassembleFunction = "-data-disassemble -a $pc -- 0",
    disassemblePC = "-data-disassemble -s $pc -e $pc+0x100 -- 0",
    listBreakpoints = "-break-list",
}

vim.iter(mifuns):each(function(name, cmd)
    Gdb[name] = function(self)
        self:send(cmd)
    end
end)

function Gdb:onInitializeContext(callback)
    table.insert(self.initializer, callback)
end

function Gdb:on(events, callback)
    vim.iter(events):each(function(event)
        if not self.listener[event] then
            self.listener[event] = {}
        end

        table.insert(self.listener[event], callback)
    end)
end

function Gdb:onReceiveMessage(callback)
    self:on({ "~" }, function(data)
        local msg = data[2]

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
            self.ctx.stopped = frame
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

function Gdb:onReceiveInstructions(callback)
    self:on({ "^done" }, function(data)
        local insns = data.asm_insns

        if insns then
            callback(insns)
        end
    end)
end

function Gdb:onChangeBreakpoints(callback)
    self:onInitializeContext(function(ctx)
        ctx.bkpt = {}
    end)

    self:onExit(function()
        self.ctx.bkpt = {}
    end)

    self:on({ "=breakpoint-created" }, function(data)
        if data.bkpt then
            callback.create(data.bkpt)

            vim.iter(pairs(data.bkpt)):each(function(id, bkpt)
                self.ctx.bkpt[id] = bkpt
            end)
        end
    end)

    self:on({ "=breakpoint-modified" }, function(data)
        if data.bkpt then
            callback.modify(data.bkpt)

            vim.iter(pairs(data.bkpt)):each(function(id, bkpt)
                self.ctx.bkpt[id] = bkpt
            end)
        end
    end)

    self:on({ "=breakpoint-deleted" }, function(data)
        local id = data.id

        if id then
            callback.delete(id)
            self.ctx.bkpt[id] = nil
        end
    end)

    self:on({ "^done" }, function(data)
        if data.BreakpointTable and data.BreakpointTable.body and data.BreakpointTable.body.bkpt then
            callback.sync(data.BreakpointTable.body.bkpt)
            self.ctx.bkpt = data.BreakpointTable.body.bkpt
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

    vim.fn.prompt_setinterrupt(bufid, function()
        self:interrupt()
    end)

    self:onReceiveMessage(function(msg)
        if vim.api.nvim_buf_is_valid(bufid) then
            local lines = vim.split(msg, "\n")
            vim.bo[bufid].buftype = "nofile"
            vim.api.nvim_buf_set_text(bufid, -1, -1, -1, -1, lines)
            vim.bo[bufid].buftype = "prompt"
        end
    end)

    return bufid
end

function Gdb:term()
    local bufid = vim.api.nvim_create_buf(true, true)
    local last = ""

    local chan = vim.api.nvim_open_term(bufid, {
        on_input = function(_, chan, _, char)
            if char:len() == 1 then
                local function send()
                    local echo = string.format("(gdb) %s\n", last)
                    vim.api.nvim_chan_send(chan, echo)
                    self:send(last)
                end

                if " " <= char and "~" >= char then
                    vim.ui.input({ prompt = "(gdb) ", default = char }, function(line)
                        if line then
                            last = line ~= "" and line or last
                            send()
                        end
                    end)
                elseif char == "\r" then
                    send()
                elseif char == "\3" then
                    self:interrupt()
                end
            end
        end,
    })

    self:onReceiveMessage(function(msg)
        if vim.api.nvim_buf_is_valid(bufid) then
            vim.api.nvim_chan_send(chan, msg)
        end
    end)

    return bufid
end

function Gdb:viwer(window, breakpoint)
    local Cache = {}

    function Cache.new()
        local self = {
            insn = {},
            func = {},
        }
        setmetatable(self, { __index = Cache })
        return self
    end

    function Cache:update(insn)
        if self.insn[insn.address] then
            local insn = self.insn[insn.address][insn.address]
            local name = insn["func-name"] or ""
            self.func[name][insn.address] = nil
            self.func[name] = next(self.func[name]) and self.func[name]
        end

        local name = insn["func-name"] or ""
        self.func[name] = self.func[name] or {}
        self.func[name][insn.address] = insn
        self.insn[insn.address] = self.func[name]
    end

    function Cache:get(name)
        local insns = vim.iter(pairs(self.func[name] or {}))
            :map(function(_, insn)
                return insn
            end)
            :totable()

        table.sort(insns, function(left, right)
            return left.address < right.address
        end)

        return insns
    end

    function Cache:load(frame, bkpt)
        local bufid, row = nil, nil
        local stat = frame.fullname and vim.uv.fs_stat(frame.fullname)

        if stat and stat.type == "file" and frame.line then
            bufid = vim.fn.bufadd(frame.fullname)
            vim.fn.bufload(bufid)
            vim.bo[bufid].buftype = "nofile"
            vim.bo[bufid].bufhidden = "hide"
            vim.bo[bufid].swapfile = false
            vim.bo[bufid].modifiable = false
            vim.bo[bufid].buflisted = false
            vim.b[bufid].__file = frame.file
            row = frame.line
        elseif frame.addr and self.insn[frame.addr] then
            local name = self.insn[frame.addr][frame.addr]["func-name"] or ""

            bufid = vim.iter(vim.api.nvim_list_bufs()):find(function(bufid)
                return vim.b[bufid].__func == name
            end)

            if not bufid then
                bufid = vim.api.nvim_create_buf(false, true)
                vim.bo[bufid].modifiable = false
                vim.bo[bufid].filetype = "asm"
                vim.b[bufid].__func = name
            end

            local insns = self:get(name)

            row = vim.iter(insns):enumerate():find(function(_, insn)
                return insn.address == frame.addr
            end)
            assert(row)

            local lines = vim.iter(insns)
                :map(function(insn)
                    local addr = insn.address
                    local func = insn["func-name"]
                    local offset = insn.offset
                    local label = func and offset and ("<%s+%04d>"):format(func, offset) or ""
                    local inst = insn.inst or ""
                    return ("0x%x%s │ %s"):format(addr, label, inst)
                end)
                :totable()

            vim.bo[bufid].modifiable = true
            vim.api.nvim_buf_set_lines(bufid, 0, -1, true, lines)
            vim.bo[bufid].modifiable = false

            local enabled = vim.iter(pairs(bkpt or {})):fold({}, function(enabled, _, bkpt)
                if bkpt.addr and bkpt.enabled ~= nil then
                    enabled[bkpt.addr] = bkpt.enabled
                end

                vim.iter(pairs(bkpt.locations or {})):each(function(_, loc)
                    if loc.addr and bkpt.enabled ~= nil and loc.enabled ~= nil then
                        enabled[loc.addr] = bkpt.enabled and loc.enabled
                    end
                end)

                return enabled
            end)

            breakpoint:clear(bufid)

            vim.iter(insns):enumerate():each(function(row, insn)
                if enabled[insn.address] ~= nil then
                    breakpoint:create(bufid, row, enabled[insn.address])
                end
            end)
        end

        return bufid, row
    end

    self:onInitializeContext(function(ctx)
        ctx.cache = Cache.new()
    end)

    self:onExit(function()
        self.ctx.cache = Cache.new()
        window:restore()
    end)

    self:onStop(function()
        local bufid, row = self.ctx.cache:load(self.ctx.stopped, self.ctx.bkpt)

        if bufid then
            window:set(bufid, row)
        elseif self.ctx.stopped.func then
            self:disassembleFunction()
        else
            self:disassemblePC()
        end
    end)

    self:onReceiveInstructions(function(insns)
        vim.iter(insns):each(function(insn)
            self.ctx.cache:update(insn)
        end)

        if self.ctx.stopped then
            local bufid, row = self.ctx.cache:load(self.ctx.stopped, self.ctx.bkpt)

            if bufid then
                window:set(bufid, row)
            end
        end
    end)

    self:onChangeBreakpoints({
        create = function(bkpt)
            vim.iter(pairs(bkpt)):each(function(_, bkpt)
                local bufid, row = self.ctx.cache:load(bkpt, self.ctx.bkpt)

                if bufid and bkpt.enabled ~= nil then
                    breakpoint:create(bufid, row, bkpt.enabled)
                end

                vim.iter(pairs(bkpt.locations or {})):each(function(_, loc)
                    local bufid, row = self.ctx.cache:load(loc, self.ctx.bkpt)

                    if bufid and bkpt.enabled ~= nil and loc.enabled ~= nil then
                        breakpoint:create(bufid, row, bkpt.enabled and loc.enabled)
                    end
                end)
            end)
        end,

        modify = function(bkpt)
            vim.iter(pairs(bkpt)):each(function(_, bkpt)
                local bufid, row = self.ctx.cache:load(bkpt, self.ctx.bkpt)

                if bufid and bkpt.enabled ~= nil then
                    breakpoint:modify(bufid, row, bkpt.enabled)
                end

                vim.iter(pairs(bkpt.locations or {})):each(function(_, loc)
                    local bufid, row = self.ctx.cache:load(loc, self.ctx.bkpt)

                    if bufid and bkpt.enabled ~= nil and loc.enabled ~= nil then
                        breakpoint:modify(bufid, row, bkpt.enabled and loc.enabled)
                    end
                end)
            end)
        end,

        delete = function(id)
            local bkpt = self.ctx.bkpt[id]

            if bkpt then
                local bufid, row = self.ctx.cache:load(bkpt, self.ctx.bkpt)

                if bufid then
                    breakpoint:delete(bufid, row)
                end

                vim.iter(pairs(bkpt.locations or {})):each(function(_, loc)
                    local bufid, row = self.ctx.cache:load(loc, self.ctx.bkpt)

                    if bufid then
                        breakpoint:delete(bufid, row)
                    end
                end)
            end
        end,

        sync = function(bkpt)
            breakpoint:clear()

            vim.iter(pairs(bkpt)):each(function(_, bkpt)
                local bufid, row = self.ctx.cache:load(bkpt, self.ctx.bkpt)

                if bufid and bkpt.enabled ~= nil then
                    breakpoint:create(bufid, row, bkpt.enabled)
                end

                vim.iter(pairs(bkpt.locations or {})):each(function(_, loc)
                    local bufid, row = self.ctx.cache:load(loc, self.ctx.bkpt)

                    if bufid and bkpt.enabled ~= nil and loc.enabled ~= nil then
                        breakpoint:create(bufid, row, bkpt.enabled and loc.enabled)
                    end
                end)
            end)
        end,
    })
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

function Window:restore()
    if vim.api.nvim_buf_is_valid(self.bufid) and vim.api.nvim_win_is_valid(self.winid) then
        vim.fn.sign_unplace(self.sign.group, { id = self.sign.id })
        vim.api.nvim_win_set_buf(self.winid, self.bufid)
        vim.api.nvim_win_set_cursor(self.winid, self.cursor)
    end
end

function Window:set(bufid, row)
    if vim.api.nvim_buf_is_valid(bufid) and vim.api.nvim_win_is_valid(self.winid) then
        vim.fn.sign_unplace(self.sign.group, { id = self.sign.id })
        vim.fn.sign_place(self.sign.id, self.sign.group, self.sign.name, bufid, { lnum = row })
        vim.api.nvim_win_set_buf(self.winid, bufid)
        vim.api.nvim_win_set_cursor(self.winid, { row, 0 })
    end
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
    if vim.api.nvim_buf_is_valid(bufid) then
        local name = self.sign.name[enabled]
        vim.fn.sign_place(0, self.sign.group, name, bufid, { lnum = row })
    end
end

function Breakpoint:modify(bufid, row, enabled)
    self:delete(bufid, row)
    self:create(bufid, row, enabled)
end

function Breakpoint:delete(bufid, row)
    if vim.api.nvim_buf_is_valid(bufid) then
        local placed = vim.fn.sign_getplaced(bufid, { group = self.sign.group, lnum = row })
        local signs = assert(placed[1]).signs

        vim.iter(signs):each(function(sign)
            vim.fn.sign_unplace(self.sign.group, { id = sign.id })
        end)
    end
end

function Breakpoint:clear(bufid)
    local args = { self.sign.group }

    if bufid then
        table.insert(args, { buffer = bufid })
    end

    vim.fn.sign_unplace(unpack(args))
end

---------------------------------------------------------------------------------------------------
local Ui = {
    default = {
        launch = {
            gdb = {
                command = { "gdb", "-i=mi" },
                executable = "gdb",
                prompt = false,
                cwd = nil,
                env = nil,
                detach = nil,
            },
            rr = {
                command = { "rr", "replay", "-i=mi" },
                executable = "rr",
                prompt = false,
                cwd = nil,
                env = nil,
                detach = nil,
            },
        },
        window = {
            split = "right",
            win = -1,
            style = "minimal",
        },
        notification = true,
    },
}

function Ui.setup()
    Window.setup()
    Breakpoint.setup()
end

function Ui.new(opts)
    local self = {
        opts = vim.tbl_deep_extend("force", Ui.default, opts or {}),
    }
    setmetatable(self, { __index = Ui })
    return self
end

function Ui:GdbOpen()
    local window = Window.new()
    local items = vim.iter(self.opts.launch)
        :filter(function(key, value)
            return not value.executable or vim.fn.executable(value.executable) == 1
        end)
        :totable()

    vim.ui.select(items, {
        format_item = function(item)
            return item[1]
        end,
    }, function(item)
        if item and not self.gdb then
            local launch = item[2]

            self.gdb = Gdb.new()
            self.gdb:viwer(window, Breakpoint.new())
            local stderr = nil

            if self.opts.notification then
                self.gdb:notify()

                stderr = function(_, text)
                    if text then
                        vim.schedule(function()
                            vim.notify(text)
                        end)
                    end
                end
            end

            local bufid = launch.prompt and self.gdb:prompt() or self.gdb:term()
            local winid = vim.api.nvim_open_win(bufid, false, self.opts.window)

            self.gdb:open(launch.command, {
                stderr = stderr,
                exit = function()
                    vim.schedule(function()
                        if vim.api.nvim_win_is_valid(winid) and #vim.api.nvim_list_wins() > 1 then
                            vim.api.nvim_win_close(winid, true)
                        end

                        if vim.api.nvim_buf_is_valid(bufid) then
                            vim.api.nvim_buf_delete(bufid, { force = true })
                        end

                        self.gdb = nil
                        window:restore()
                    end)
                end,
                cwd = launch.cwd,
                env = launch.env,
                detach = launch.detach,
            })
        end
    end)
end

function Ui:GdbClose()
    if self.gdb then
        self.gdb:close()
    end
end

function Ui:GdbInterrupt()
    if self.gdb then
        self.gdb:interrupt()
    end
end

function Ui:GdbSend()
    if self.gdb then
        vim.ui.input({ prompt = "(gdb) " }, function(line)
            if line then
                self.gdb:send(line)
            end
        end)
    end
end

function Ui:GdbSyncBreakpoints()
    if self.gdb then
        self.gdb:listBreakpoints()
    end
end

function Ui:GdbToggleCreateBreakpoint()
    if self.gdb and self.gdb.ctx.bkpt then
        local winid = vim.api.nvim_get_current_win()
        local bufid = vim.api.nvim_win_get_buf(winid)
        local cursor = vim.api.nvim_win_get_cursor(winid)
        local cmd = nil

        if vim.b[bufid].__file then
            local file = vim.b[bufid].__file
            local row = cursor[1]
            local id = vim.iter(pairs(self.gdb.ctx.bkpt)):find(function(_, bkpt)
                return bkpt.file == file and bkpt.line == row
            end)
            cmd = id and ("delete %d"):format(id) or ("break %s:%d"):format(file, row)
        elseif vim.b[bufid].__func and self.gdb.ctx.cache then
            local insns = self.gdb.ctx.cache:get(vim.b[bufid].__func)
            local insn = insns[cursor[1]]
            local addr = insn and insn.address
            local id = vim.iter(pairs(self.gdb.ctx.bkpt)):find(function(_, bkpt)
                return bkpt.addr == addr
            end)
            cmd = id and ("delete %d"):format(id) or ("break *0x%x"):format(addr)
        end

        if cmd then
            self.gdb:send(cmd)
        end
    end
end

function Ui:GdbToggleEnableBreakpoint()
    if self.gdb and self.gdb.ctx then
        local items = vim.iter(pairs(self.gdb.ctx.bkpt or {})):fold({}, function(items, id, bkpt)
            table.insert(items, { ("%d"):format(id), bkpt })

            vim.iter(pairs(bkpt.locations or {})):each(function(subid, loc)
                table.insert(items, { ("%d.%d"):format(id, subid), loc })
            end)

            return items
        end)

        vim.ui.select(items, {
            format_item = function(item)
                local number, bkpt = unpack(item)
                local enabled = nil

                if bkpt.enabled ~= nil then
                    enabled = bkpt.enabled and "E" or "D"
                else
                    enabled = " "
                end

                local addr = bkpt.addr and ("0x%x"):format(bkpt.addr) or ""
                local file = bkpt.file and bkpt.file or ""
                local line = bkpt.line and ("%d"):format(bkpt.line) or ""
                return vim.iter({ number, enabled, "│", addr, file, line }):join(" ")
            end,
        }, function(item)
            if item then
                local number, bkpt = unpack(item)

                if bkpt.enabled ~= nil then
                    local cmd = ("%s %s"):format(bkpt.enabled and "disable" or "enable", number)
                    self.gdb:send(cmd)
                end
            end
        end)
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

function M.setup(opts)
    Ui.setup()
    local ui = Ui.new(opts)

    local cmds = {
        "GdbOpen",
        "GdbClose",
        "GdbInterrupt",
        "GdbSend",
        "GdbSyncBreakpoints",
        "GdbToggleCreateBreakpoint",
        "GdbToggleEnableBreakpoint",
    }

    vim.iter(cmds):each(function(cmd)
        vim.api.nvim_create_user_command(cmd, function()
            ui[cmd](ui)
        end, {})
    end)
end

return M
