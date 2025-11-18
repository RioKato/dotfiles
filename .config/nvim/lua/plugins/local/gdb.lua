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
local Logger = { enabled = false }

function Logger:enable()
    self.enabled = true
end

function Logger:write(obj)
    if self.enabled then
        if not self.bufid then
            self.bufid = vim.api.nvim_create_buf(true, true)
        end

        local text = vim.inspect(obj)
        local lines = vim.split(text, "\n")
        vim.api.nvim_buf_set_lines(self.bufid, -1, -1, false, lines)
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
                    Logger:write(result)

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
        Logger:write({ send = cmd })
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

function Gdb:disassemblePC(offset)
    local cmd = ("-data-disassemble -s $pc -e $pc+%d -- 0"):format(offset)
    self:send(cmd)
end

function Gdb:breakList()
    self:send("-break-list")
end

function Gdb:breakInsert(pos)
    local cmd = ("-break-insert %s"):format(pos)
    self:send(cmd)
end

function Gdb:breakDelete(id)
    local cmd = ("-break-delete %d"):format(id)
    self:send(cmd)
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
            local addr = tonumber(frame.addr)

            if addr then
                local files = {}
                table.insert(files, frame.file)
                table.insert(files, frame.fullname)
                local row = tonumber(frame.line)
                local unknowns = { "??" }
                local func = not vim.tbl_contains(unknowns, frame.func) and frame.func or nil

                ctx.stopped = {
                    addr = addr,
                    files = files,
                    row = row,
                    func = func,
                }

                callback(ctx)
            end
        end
    end)

    self:on({ "*running" }, function(ctx)
        ctx.stopped = nil
    end)
end

function Gdb:onExit(callback)
    self:on({ "*stopped" }, function(_, data)
        local reason = data.reason

        if reason and vim.startswith(reason, "exited") then
            callback()
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

function Gdb:onListBreakpoints(callback)
    self:on({ "^done" }, function(ctx, data)
        if data.BreakpointTable and data.BreakpointTable.body and data.BreakpointTable.body.bkpt then
            ctx.bkpt = {}
            vim.iter(data.BreakpointTable.body.bkpt):each(function(bkpt)
                local id = tonumber(bkpt.number)

                if id then
                    ctx.bkpt[id] = bkpt
                end
            end)
            callback(ctx)
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

function Gdb:code(window, offset)
    local Cache = {}

    function Cache.new()
        local self = { buf = {} }
        setmetatable(self, { __index = Cache })
        return self
    end

    function Cache:set(bufid, range)
        self.buf[bufid] = range
    end

    function Cache:get(addr)
        vim.iter(pairs(self.buf)):each(function(bufid)
            if not vim.api.nvim_buf_is_valid(bufid) then
                self.buf[bufid] = nil
            end
        end)

        return vim.iter(pairs(self.buf)):find(function(_, range)
            return range[addr]
        end)
    end

    self:onStop(function(ctx)
        local stopped = assert(ctx.stopped)
        local found = vim.iter(stopped.files):find(function(file)
            local stat = vim.uv.fs_stat(file)
            return stat and stat.type == "file"
        end)

        local bufid, row = nil, nil

        if found and stopped.row then
            bufid, row = vim.fn.bufadd(found), stopped.row
            vim.fn.bufload(bufid)
            vim.bo[bufid].buftype = "nofile"
            vim.bo[bufid].bufhidden = "hide"
            vim.bo[bufid].swapfile = false
            vim.bo[bufid].modifiable = false
        elseif ctx.cache then
            local ok, range = ctx.cache:get(stopped.addr)

            if ok then
                bufid, row = ok, assert(range[stopped.addr])
            end
        end

        if bufid and row then
            window:display(bufid, row)
        elseif stopped.func then
            self:disassembleFunction()
        else
            self:disassemblePC(offset or 0x100)
        end
    end)

    self:on({ "^done" }, function(ctx, data)
        local stopped = ctx.stopped
        local asm_insns = data.asm_insns

        if stopped and asm_insns then
            local range = vim.iter(asm_insns):enumerate():fold({}, function(init, row, insn)
                init[tonumber(insn.address)] = row
                return init
            end)

            local row = range[stopped.addr]

            if row then
                local lines = vim.iter(asm_insns)
                    :map(function(insn)
                        local address = insn.address or ""
                        local name = insn["func-name"]
                        local offset = tonumber(insn.offset)
                        local label = name and offset and ("<%s+%03d>"):format(name, offset) or ""
                        local inst = insn.inst or ""
                        return ("%s%s │ %s"):format(address, label, inst)
                    end)
                    :totable()

                local bufid = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(bufid, 0, -1, true, lines)
                vim.bo[bufid].modifiable = false
                vim.bo[bufid].filetype = "asm"
                window:display(bufid, row)

                if not ctx.cache then
                    ctx.cache = Cache.new()
                end

                ctx.cache:set(bufid, range)
            end
        end
    end)

    self:onExit(function()
        ctx.stopped = nil
        ctx.cache = nil
        window:fallback()
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
local Window = {}

function Window.new()
    local self = {
        winid = vim.api.nvim_get_current_win(),
        bufid = vim.api.nvim_get_current_buf(),
        cursor = vim.api.nvim_win_get_cursor(0),
        sign = {
            id = 1,
            name = "GdbLine",
            group = "",
        },
    }

    setmetatable(self, { __index = Window })
    return self
end

function Window:fallback()
    vim.fn.sign_unplace(self.sign.group, { id = self.sign.id })
    vim.api.nvim_win_set_buf(self.winid, self.bufid)
    vim.api.nvim_win_set_cursor(self.winid, self.cursor)
end

function Window:display(bufid, row)
    vim.fn.sign_unplace(self.sign.group, { id = self.sign.id })
    vim.fn.sign_place(self.sign.id, self.sign.group, self.sign.name, bufid, { lnum = row })
    vim.api.nvim_win_set_buf(self.winid, bufid)
    vim.api.nvim_win_set_cursor(self.winid, { row, 0 })
end

---------------------------------------------------------------------------------------------------
local function setupBreakpoints(gdb)
    gdb:onListBreakpoints(function(ctx)
        -- vim.fn.sign_unplace(self.sign.group)

        vim.iter(pairs(assert(ctx.bkpt))):each(function(_, info)
            local files = {}
            table.insert(files, info.file)
            table.insert(files, info.fullname)
            local row = tonumber(info.line)
            local addr = tonumber(info.addr)

            local found = vim.iter(files):find(function(file)
                local stat = vim.uv.fs_stat(file)
                return stat and stat.type == "file"
            end)

            if found and row then
                local bufid = vim.fn.bufadd(found)
                vim.fn.bufload(bufid)
                -- vim.fn.sign_place(0, self.sign.group, self.sign.name, bufid, { lnum = row })
            elseif ctx.cache then
                local bufid, range = ctx.cache:get(addr)

                if bufid then
                    local row = assert(range[addr])
                end
            end
        end)
    end)
end

local function insertBreakpointAt(gdb)
    local path = vim.fn.expand("%:p")
    local pos = ""

    if path ~= "" then
        path = resolveDebuginfodPath(path) or path
        pos = ("%s:%d"):format(path, vim.fn.line("."))
    else
        local addr = vim.fn.getline("."):match("0x%x+")

        if not addr then
            vim.notify("can't insert breakpoint")
            return
        end

        pos = ("*%s"):format(addr)
    end

    gdb:breakInsert(pos)
end

local function resolveDebuginfodPath(path)
    if path:match("debuginfod") then
        path = path:match("#.+$")

        if path then
            return path:gsub("#", "/")
        end
    end
end

---------------------------------------------------------------------------------------------------
local function setup()
    Logger:enable()
    vim.fn.sign_define("GdbLine", { linehl = "GdbLine" })
    vim.api.nvim_set_hl(0, "GdbLine", { reverse = true, ctermbg = "darkblue" })

    gdb = Gdb.new()
    local bufid = gdb:prompt()
    vim.api.nvim_open_win(bufid, false, {
        split = "below",
        win = -1,
        style = "minimal",
        height = 10,
    })

    local window = Window.new()
    gdb:code(window)
    gdb:notify()
    setupBreakpoints(gdb)
    gdb:open({ "gdb", "-i=mi" })
end

setup()
