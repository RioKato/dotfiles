set auto-load safe-path /
set disassembly-flavor intel
set disable-randomization on
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
  condition $bpnum $_any_caller_is("$arg0", (unsigned long)-1)
end

define vim
  shell vim $arg0
end

define declare
  shell gcc -g -fno-eliminate-unused-debug-types -x c -c -o temp.o $arg0
  add-symbol-file temp.o
  shell rm temp.o
end

define dlimport
  shell gcc -g -shared -fPIC -o temp.so $arg0
  call dlopen("./temp.so", 2)
  shell rm temp.so
end

define offset
  pipe info proc mappings | awk -v addr=$arg0 \
  '$1~/0x[a-f0-9]+/{ \
    start=strtonum($1); addr=strtonum(addr); \
    if(start < addr) printf "+0x%016x %s\n", (addr-start), $0; \
    if(start >= addr) printf "-0x%016x %s\n", (start-addr), $0; \
  }'
end

define xxd
  dump binary memory temp.bin $arg1 $arg2
  shell xxd -g 8 -R never -o $arg1 temp.bin $arg0
  shell rm temp.bin
end

define diff
  shell git diff --no-index --color-words='[a-f0-9]{16}' $arg0 $arg1
end

define fzf_bpnum_exec
  pipe info breakpoints | grep '^[0-9]' | fzf-tmux +m --bind 'enter:become('$arg0')' $FZF_TMUX_OPTS
end

define e
  fzf_bpnum_exec 'tmux send enable Space {1} Enter'
end

define d
  fzf_bpnum_exec 'tmux send disable Space {1} Enter'
end

define D
  fzf_bpnum_exec 'tmux send del Space {1} Enter'
end

define init-gef
  source ~/.gef.py
  gef config theme.registers_register_name "white"
  gef config theme.dereference_register_value "white"
  gef config context.nb_lines_backtrace 4
  gef config context.nb_lines_code 5

  python
if os.getenv('TMUX'):
  command = [
    'tmux',
    'split-window', '-h', '-f', '-P', '-F#{session_name}:#{window_index}.#{pane_index}-#{pane_tty}', 'cat', ';',
    'select-pane', '-L'
  ]
  proc = subprocess.run(command, capture_output=True, text=True, check=True)
  pane, pty = proc.stdout.strip().split('-')
  command = ['tmux', 'kill-pane', '-t', pane]
  atexit.register(lambda : subprocess.run(command, stderr=subprocess.DEVNULL))
  gdb.execute(f'gef config context.redirect {pty}')
  end
end

init-gef
