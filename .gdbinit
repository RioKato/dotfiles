set auto-load safe-path /
set disassembly-flavor intel
set disable-randomization off
set follow-fork-mode parent
set history filename ~/.gdb_history
set pagination off
set confirm off
set print pretty on
set print demangle
set print asm-demangle
set style enabled off
handle SIGALRM ignore
set debuginfod enabled on
alias -a rf = reverse-finish


define a
  source breakpoints.gdb

  define aa
    save breakpoints breakpoints.gdb
  end

  define hook-quit
    aa
  end
end

define wi
  watch *(unsigned int*)($arg0)
end

define wl
  watch *(unsigned long*)($arg0)
end

define wa
  watch *(unsigned char [$arg1]*)($arg0)
end

define rwi
  rwatch *(unsigned int*)($arg0)
end

define rwl
  rwatch *(unsigned long*)($arg0)
end

define rwa
  rwatch *(unsigned char [$arg1]*)($arg0)
end

define awi
  awatch *(unsigned int*)($arg0)
end

define awl
  awatch *(unsigned long*)($arg0)
end

define awa
  awatch *(unsigned char [$arg1]*)($arg0)
end

define cc
  if $argc < 2
    condition $bpnum $_any_caller_is("$arg0", (unsigned long)-1)
  else
    condition $arg0 $_any_caller_is("$arg1", (unsigned long)-1)
  end
end

define dlog
  shell rm dlog.out
  break $arg0
  commands
    pipe printf "%d.%d,%#0lx,%#0lx,%#0lx,%#0lx,%#0lx,%#0lx\n", $_hit_bpnum, $_hit_locno, $rdi, $rsi, $rdx, $rcx, $r8, $r9 | tee -a dlog.out
    continue
  end
end

define vim
  shell vim $arg0
end

define declare
  shell gcc -g -fno-eliminate-unused-debug-types -x c -c -o /tmp/gdb $arg0
  add-symbol-file /tmp/gdb
  shell rm -f /tmp/gdb
end

define dlimport
  shell gcc -g -shared -fPIC -o /tmp/gdb $arg0
  call dlopen("/tmp/gdb", 2)
  shell rm -f /tmp/gdb
end

define xxd
  dump binary memory /tmp/gdb $arg1 $arg2
  shell xxd -g 8 -R never -o $arg1 /tmp/gdb $arg0
  shell rm -f /tmp/gdb
end

define diff
  shell $(command -v colordiff diff | head -n 1) -y $arg0 $arg1 | less
end

define set-conv
  shell sed -i -E 's/..*/set \$$arg0 = "&"/' $arg1
  source $arg1
  # python with open('$arg1') as fd: gdb.set_convenience_variable('$arg0', fd.read())
  shell rm -f $arg1
end

define fzf-bps
  pipe info breakpoints | grep '^[0-9]' | fzf-tmux +m +s --bind 'enter:become(echo -n {1} > /tmp/gdb)' $FZF_TMUX_OPTS
  set-conv bpstr /tmp/gdb
end

define e
  fzf-bps
  eval "enable %s", $bpstr
end

define d
  fzf-bps
  eval "disable %s", $bpstr
end

define D
  fzf-bps
  eval "delete %s", $bpstr
end

define tmux-tty
  shell tmux split-window -h -f -d -P -F#{pane_tty} cat | tr -d '\n' > /tmp/gdb
  set-conv tty /tmp/gdb
end

python
class OffsetCommand(gdb.Command):
    def __init__(self):
        super().__init__('offset', gdb.COMMAND_USER)

    def invoke(self, arg: str, _):
        target = gdb.parse_and_eval(arg)
        target = int(target)
        hex = re.compile(r'(0x[0-9a-f]+)')
        GREEN = '\033[32m'
        PURPLE = '\033[35m'
        END = '\033[0m'

        for line in gdb.execute('info proc mappings', False, True).splitlines():
            if found := hex.search(line):
                start, = found.groups()
                start = int(start, 16)
                if target > start:
                    print(f'{GREEN}+{target-start:#019x}{END} {line}')
                else:
                    print(f'{PURPLE}-{start-target:#019x}{END} {line}')
OffsetCommand()
end

define init-gef
  source ~/.gef.py
  gef config theme.registers_register_name "white"
  gef config theme.dereference_register_value "white"
  gef config context.nb_lines_backtrace 4
  gef config context.nb_lines_code 5
  gef config gef.disable_target_remote_overwrite True

  define ow
    tmux-tty
    eval "gef config context.redirect \"%s\"", $tty
  end
end

init-gef
