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
        elseif data[1] == "func" then
            local unknowns = { "??", "" }
            data[2] = not vim.tbl_contains(unknowns, data[2]) and data[2] or nil
        elseif data[1] == "func-name" then
            data[2] = data[2] ~= "" and data[2] or nil
        end

        data.pair = true
        return data
    end

    local function norm(data)
        local dupkey = { "bkpt" }

        return vim.iter(data):fold({}, function(left, right)
            if right.pair then
                local key = right[1]
                local value = right[2]

                if vim.tbl_contains(dupkey, key) then
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

function Gdb:open(cmd, opts)
    if not self.job then
        local buf = ""

        self.ctx = {}
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
    local create = callback.create
    local modify = callback.modify
    local delete = callback.delete
    local sync = callback.sync

    local function dict(bkpts)
        return vim.iter(bkpts):fold({}, function(left, right)
            if right.number then
                left[right.number] = right
            end

            return left
        end)
    end

    if create then
        self:on({ "=breakpoint-created" }, function(data)
            if data.bkpt then
                local bkpts = dict(data.bkpt)
                create(bkpts)
                self.ctx.bkpts = self.ctx.bkpts or {}

                vim.iter(pairs(bkpts)):each(function(id, bkpt)
                    self.ctx.bkpts[id] = bkpt
                end)
            end
        end)
    end

    if modify then
        self:on({ "=breakpoint-modified" }, function(data)
            if data.bkpt then
                local bkpts = dict(data.bkpt)
                modify(bkpts)
                self.ctx.bkpts = self.ctx.bkpts or {}

                vim.iter(pairs(bkpts)):each(function(id, bkpt)
                    self.ctx.bkpts[id] = bkpt
                end)
            end
        end)
    end

    if delete then
        self:on({ "=breakpoint-deleted" }, function(data)
            local id = data.id

            if id then
                delete(id)
                self.ctx.bkpts = self.ctx.bkpts or {}
                self.ctx.bkpts[id] = nil
            end
        end)
    end

    if sync then
        self:on({ "^done" }, function(data)
            if data.BreakpointTable and data.BreakpointTable.body and data.BreakpointTable.body.bkpt then
                local bkpts = dict(data.BreakpointTable.body.bkpt)
                sync(bkpts)
                self.ctx.bkpts = bkpts
            end
        end)
    end
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
        if vim.api.nvim_buf_is_valid(bufid) then
            local lines = vim.split(msg, "\n")
            vim.bo[bufid].buftype = "nofile"
            vim.api.nvim_buf_set_text(bufid, -1, -1, -1, -1, lines)
            vim.bo[bufid].buftype = "prompt"
        end
    end)

    return bufid
end

function Gdb:viwer(window, breakpoint)
    local Cache = {}

    function Cache.new()
        local self = { insns = {}, funcs = {} }
        setmetatable(self, { __index = Cache })
        return self
    end

    function Cache:insert(insn)
        local address = insn.address

        if address then
            self.insns[address] = insn
            local name = insn["func-name"] or ""
            local func = self.funcs[name] or { addrs = {} }
            func.addrs[address] = true
            func.updated = true
            self.funcs[name] = func
        end
    end

    function Cache:remove(address)
        local insn = self.insns[address]

        if insn then
            self.insns[address] = nil
            local name = insn["func-name"] or ""
            local func = assert(self.funcs[name])
            func.addrs[address] = nil
            func.updated = true

            if vim.tbl_isempty(func.addrs) then
                func = nil
            end

            self.funcs[name] = func
        end
    end

    function Cache:update(insn)
        self:remove(insn.address)
        self:insert(insn)
    end

    function Cache:get(address)
        local insn = self.insns[address]

        if insn then
            local name = insn["func-name"] or ""
            return assert(self.funcs[name])
        end
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
        elseif cache then
            local func = cache:get(frame.addr)

            if func then
                if not func.bufid or not vim.api.nvim_buf_is_valid(func.bufid) then
                    func.bufid = vim.api.nvim_create_buf(false, true)
                    vim.bo[func.bufid].modifiable = false
                    vim.bo[func.bufid].filetype = "asm"
                    func.updated = true
                end

                bufid = func.bufid

                local insns = vim.iter(pairs(func.addrs))
                    :map(function(addr)
                        return assert(cache.insns[addr])
                    end)
                    :totable()

                table.sort(insns, function(left, right)
                    return left.address < right.address
                end)

                row = vim.iter(insns):enumerate():find(function(_, insn)
                    return insn.address == frame.addr
                end)
                assert(row)

                if func.updated then
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

                    local exists = vim.iter(pairs(self.ctx.bkpts or {})):fold({}, function(exists, _, bkpt)
                        exists[bkpt.addr] = true
                        return exists
                    end)

                    breakpoint:clear(bufid)

                    vim.iter(insns):enumerate():each(function(row, insn)
                        if exists[insn.address] then
                            breakpoint:create(bufid, row)
                        end
                    end)

                    func.updated = false
                end
            end
        end

        return bufid, row
    end

    self:onStop(function()
        local bufid, row = load(self.ctx.cache, self.ctx.stopped)

        if bufid then
            window:set(bufid, row)
        elseif self.ctx.stopped.func then
            self:disassembleFunction()
        else
            self:disassemblePC()
        end
    end)

    self:onReceiveInstructions(function(insns)
        self.ctx.cache = self.ctx.cache or Cache.new()

        vim.iter(insns):each(function(insn)
            self.ctx.cache:update(insn)
        end)

        if self.ctx.stopped then
            local bufid, row = load(self.ctx.cache, self.ctx.stopped)

            if bufid then
                window:set(bufid, row)
            end
        end
    end)

    self:onExit(function()
        self.ctx.cache = nil
        window:restore()
    end)

    self:onChangeBreakpoints({
        create = function(bkpts)
            vim.iter(pairs(bkpts)):each(function(_, bkpt)
                local bufid, row = load(self.ctx.cache, bkpt)

                if bufid then
                    breakpoint:create(bufid, row, bkpt.enabled)
                end
            end)
        end,

        modify = function(bkpts)
            vim.iter(pairs(bkpts)):each(function(_, bkpt)
                local bufid, row = load(self.ctx.cache, bkpt)

                if bufid then
                    breakpoint:modify(bufid, row, bkpt.enabled)
                end
            end)
        end,

        delete = function(id)
            local bkpt = self.ctx.bkpts and self.ctx.bkpts[id]

            if bkpt then
                local bufid, row = load(self.ctx.cache, bkpt)

                if bufid then
                    breakpoint:delete(bufid, row)
                end
            end
        end,

        sync = function(bkpts)
            breakpoint:clear()

            vim.iter(pairs(bkpts)):each(function(_, bkpt)
                local bufid, row = load(self.ctx.cache, bkpt)

                if bufid then
                    breakpoint:create(bufid, row, bkpt.enabled)
                end
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
        local name = self.sign.name[enabled or enabled == nil]
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
                cwd = nil,
                env = nil,
                detach = nil,
            },
            rr = {
                command = { "rr", "replay", "-i=mi" },
                executable = "rr",
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
        debuginfod = {
            path = "~/.cache/debuginfod_client",
            resolve = function(path)
                return path:match("#([^#]+)$")
            end,
        },
    },
}

function Ui.setup()
    Window.setup()
    Breakpoint.setup()
end

function Ui.new(opts)
    local self = {
        opts = vim.tbl_deep_extend("force", Ui.default, opts or {}),
        gdb = Gdb.new(),
        opened = false,
    }
    setmetatable(self, { __index = Ui })
    return self
end

function Ui:GdbOpen()
    if not self.opened then
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
            if item then
                local launch = item[2]
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

                local bufid = self.gdb:prompt()
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

                            window:restore()
                            self.gdb = Gdb.new()
                            self.opened = false
                        end)
                    end,
                    cwd = launch.cwd,
                    env = launch.env,
                    detach = launch.detach,
                })

                self.opened = true
            end
        end)
    end
end

function Ui:GdbClose()
    self.gdb:close()
end

function Ui:GdbInterrupt()
    self.gdb:interrupt()
end

function Ui:GdbSyncBreakpoints()
    self.gdb:listBreakpoints()
end

function Ui:GdbToggleBreakpoint()
    if self.gdb.ctx then
        local bkpts = self.gdb.ctx.bkpts or {}
        local cache = self.gdb.ctx.cache
        local winid = vim.api.nvim_get_current_win()
        local bufid = vim.api.nvim_win_get_buf(winid)
        local cursor = vim.api.nvim_win_get_cursor(winid)
        local path = vim.api.nvim_buf_get_name(bufid)
        local cmd = nil

        if path ~= "" then
            local file = vim.fs.basename(path)

            if self.opts.debuginfod then
                local home = vim.fs.abspath(self.opts.debuginfod.path)

                if vim.fs.relpath(home, path) then
                    file = self.opts.debuginfod.resolve(path) or file
                end
            end

            local found = vim.iter(pairs(bkpts)):find(function(_, bkpt)
                return bkpt.file == file and bkpt.line == cursor[1]
            end)
            cmd = found and ("delete %d"):format(found) or ("break %s:%d"):format(file, cursor[1])
        elseif cache then
            local name = vim.iter(cache.funcs):find(function(_, func)
                return func.bufid == bufid
            end)
            local func = cache.funcs[name]

            if func then
                local insns = vim.iter(pairs(func.addrs))
                    :map(function(addr)
                        return assert(cache.insns[addr])
                    end)
                    :totable()

                table.sort(insns, function(left, right)
                    return left.address < right.address
                end)

                local insn = insns[cursor[1]]

                if insn then
                    local found = vim.iter(pairs(bkpts)):find(function(_, bkpt)
                        return bkpt.addr == insn.address
                    end)
                    cmd = found and ("delete %d"):format(found) or ("break *0x%x"):format(insn.address)
                end
            end
        end

        if cmd then
            self.gdb:send(cmd)
        end
    end
end

function Ui:GdbToggleEnableBreakpoint()
    if self.gdb.ctx then
        local bkpts = self.gdb.ctx.bkpts or {}
        local items = vim.iter(pairs(bkpts))
            :map(function(_, bkpt)
                return bkpt
            end)
            :totable()

        table.sort(items, function(left, right)
            return left.number > right.number
        end)

        vim.ui.select(items, {
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
                local cmd = ("%s %d"):format(item.enabled and "disable" or "enable", item.number)
                self.gdb:send(cmd)
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
        "GdbSyncBreakpoints",
        "GdbToggleBreakpoint",
        "GdbToggleEnableBreakpoint",
    }

    vim.iter(cmds):each(function(cmd)
        vim.api.nvim_create_user_command(cmd, function()
            ui[cmd](ui)
        end, {})
    end)
end

return M
