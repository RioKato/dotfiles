local util = {}

function util.assign_keys(keys, opts)
    vim.iter(keys):each(function(key)
        vim.keymap.set(key[1], key[2], key[3], opts)
    end)
end

local init = {}

function init.editor()
    vim.opt.encoding = "utf-8"
    vim.opt.autoindent = true
    vim.opt.expandtab = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.wrap = false
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undofile = false
    vim.opt.autoread = true
    vim.opt.wildmenu = true
    vim.opt.gdefault = true
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.wrapscan = true
    vim.opt.incsearch = true
    vim.opt.hlsearch = true
    vim.opt.inccommand = "split"
    vim.opt.hidden = true
    vim.opt.jumpoptions = "stack"
    vim.opt.splitright = true
    vim.opt.splitbelow = true
    vim.opt.winminwidth = 0
    vim.opt.winminheight = 0
    vim.opt.virtualedit = "block"
    vim.opt.showmatch = true
    vim.opt.matchtime = 1
    vim.opt.mouse = ""
    vim.opt.timeoutlen = 10000
    vim.opt.clipboard:append("unnamedplus")
    vim.opt.shortmess:append("I")
    vim.g.mapleader = " "
    vim.g.loaded_matchparen = 1
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    local keys = {
        { { "n", "x" }, "j", "gj" },
        { { "n", "x" }, "k", "gk" },
        { { "n", "x" }, "gj", "j" },
        { { "n", "x" }, "gk", "k" },
        { "n", "x", '"_x' },
        { "c", "<C-f>", "<right>" },
        { "c", "<C-b>", "<left>" },
        { "c", "<C-a>", "<home>" },
        { "c", "<C-e>", "<end>" },
        { "n", "<C-w>z", "<cmd>horizontal resize | vertical resize<cr>" },
        { "n", "<C-w>t", "<cmd>tab sbuffer<cr>" },
        { "n", "<C-w>n", "<cmd>tabnext<cr>" },
        { "n", "<C-w>p", "<cmd>tabprevious<cr>" },
        { "n", "<C-w>o", "<nop>" },
        { "n", "<C-w>T", "<nop>" },
        { "n", "gt", "<nop>" },
        { "n", "gT", "<nop>" },
        { "t", "<esc>", "<c-\\><c-n>" },
    }

    util.assign_keys(keys)

    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "make" },
        callback = function(ev)
            vim.bo[ev.buf].expandtab = false
        end,
    })
end

function init.appearance()
    vim.opt.termguicolors = true
    vim.opt.syntax = "on"
    vim.opt.number = true
    vim.opt.cursorline = true
    vim.opt.cursorlineopt = "number"
    vim.opt.signcolumn = "number"
    vim.opt.laststatus = 3
    vim.opt.statusline = "%= [%{mode()}]%r %t %="
    vim.opt.showtabline = 0
    vim.opt.winborder = "single"
    vim.opt.fillchars = {
        stl = "─",
        stlnc = "─",
        eob = " ",
    }
    vim.g.qf_disable_statusline = 1

    vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
        callback = function()
            local hls = {
                "Normal",
                "NormalNC",
                "StatusLine",
                "StatusLineNC",
                "TabLine",
                "TabLineFill",
                "StatusLineTerm",
                "StatusLineTermNC",
                "WinSeparator",
                "NormalFloat",
                "FloatBorder",
                "FloatTitle",
                "FloatFooter",
                "Pmenu",
            }

            vim.iter(hls):each(function(hl)
                vim.api.nvim_set_hl(0, hl, {})
            end)
        end,
    })
end

function init.quickfix()
    local keys = {
        { "n", "<C-l>", "<cmd>copen<cr>" },
        { "n", "<C-n>", "<cmd>silent! cnext<cr>" },
        { "n", "<C-p>", "<cmd>silent! cprevious<cr>" },
    }

    util.assign_keys(keys)

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function(ev)
            local keys = {
                { "n", "q", "<cmd>cclose<cr>" },
                { "n", "<C-o>", "<cmd>silent! colder<cr>" },
                { "n", "<C-i>", "<cmd>silent! cnewer<cr>" },
                { "n", "<enter>", "<cmd>.cc<cr>" },
            }

            util.assign_keys(keys, { buffer = ev.buf })
        end,
    })
end

function init.lsp()
    vim.diagnostic.config({
        signs = true,
        underline = false,
        virtual_lines = true,
    })

    vim.diagnostic.enable(false)

    local function diagnostic()
        local enabled = not vim.diagnostic.is_enabled()
        vim.diagnostic.enable(enabled)
        vim.notify(string.format("Diagnostic: %s", enabled and "enable" or "disable"))
    end

    local keys = {
        -- stylua: ignore start
        { "n", "<C-h>", function() vim.lsp.buf.hover() end },
        { "n", "<leader>ld", diagnostic },
        { "n", "<leader>lr", function() vim.lsp.buf.rename() end },
        { "n", "<leader>lc", function() vim.lsp.buf.code_action() end },
        -- stylua: ignore end
    }

    util.assign_keys(keys)
end

function init.debug()
    vim.cmd.packadd("termdebug")

    local termdebug_config = {
        gdb = {
            command = { "gdb" },
            command_add_args = function(cmd, pty)
                -- stylua: ignore start
                return {
                    "gdb",
                    "-tty", pty,
                    "-quiet",
                    "-iex", "set pagination off",
                    "-iex", "set mi-async on",
                    "-ex", "echo startupdone\n",
                }
                -- stylua: ignore end
            end,
        },
        rr = {
            command = { "rr" },
            command_add_args = function(cmd, pty)
                -- stylua: ignore start
                return {
                    "rr", "replay",
                    "--tty", pty,
                    "--",
                    "-quiet",
                    "-iex", "set pagination off",
                    "-iex", "set mi-async on",
                    "-ex", "echo startupdone\n",
                }
                -- stylua: ignore end
            end,
        },
    }

    vim.g.termdebug_config = {
        command = termdebug_config.gdb.command,
        command_add_args = termdebug_config.gdb.command_add_args,
        map_K = 0,
        map_minus = 0,
        map_plus = 0,
        disasm_window = 1,
        variables_window = 1,
        popup = 0,
    }

    local function select_debugger()
        local items = vim.iter(termdebug_config)
            :map(function(_, value)
                return value
            end)
            :totable()

        vim.ui.select(items, {
            prompt = "Debugger",
            format_item = function(item)
                return vim.iter(item.command):join(" ")
            end,
        }, function(item)
            if item then
                local termdebug_config = vim.g.termdebug_config
                termdebug_config.command = item.command
                termdebug_config.command_add_args = item.command_add_args
                vim.g.termdebug_config = termdebug_config
            end
        end)
    end

    local function select_window()
        local items = { "Gdb", "Source", "Program", "Asm", "Var" }

        vim.ui.select(items, {
            prompt = "Window",
        }, function(item)
            vim.cmd(item)
        end)
    end

    local function start()
        local args = vim.fn.input("TermdebugCommand ", "", "file")
        vim.cmd(string.format("TermdebugCommand %s", args))
    end

    local keys = {
        { "n", "<leader>Dd", select_window },
        { "n", "<leader>DD", select_debugger },
        { "n", "<leader>Da", start },
        { "n", "<leader>Dr", "<cmd>Run<cr>" },
        { "n", "<leader>DR", "<cmd>Stop<cr>" },
        { "n", "<leader>Db", "<cmd>Break<cr>" },
        { "n", "<leader>DB", "<cmd>Clear<cr>" },
        { "n", "<leader>Ds", "<cmd>Step<cr>" },
        { "n", "<leader>Dn", "<cmd>Over<cr>" },
        { "n", "<leader>Dc", "<cmd>Continue<cr>" },
        { "n", "<leader>Df", "<cmd>Finish<cr>" },
    }

    util.assign_keys(keys)
end

function init.plugins()
    vim.pack.add({
        "https://github.com/folke/lazy.nvim",
    })

    require("lazy").setup({
        { import = "plugins.lazy" },
    })

    require("plugins.local")
end

function init:all()
    self.editor()
    self.appearance()
    self.quickfix()
    self.lsp()
    self.debug()
    self.plugins()
end

init:all()
