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

define hookpost-break
  save breakpoints breakpoints.gdb
end

define hookpost-watch
  save breakpoints breakpoints.gdb
end

define hookpost-rwatch
  save breakpoints breakpoints.gdb
end

define hookpost-awatch
  save breakpoints breakpoints.gdb
end

define hookpost-condition
  save breakpoints breakpoints.gdb
end

define hookpost-enable
  save breakpoints breakpoints.gdb
end

define hookpost-disable
  save breakpoints breakpoints.gdb
end

define load-breakpoints
  source breakpoints.gdb
end

define vim
  shell tmux split-window vim $arg0
end

define e
  pipe info breakpoints | grep '^[0-9]' | fzf-tmux +m --bind 'enter:become(tmux send enable " " {1} Enter)' $FZF_TMUX_OPTS
end

define d
  pipe info breakpoints | grep '^[0-9]' | fzf-tmux +m --bind 'enter:become(tmux send disable " " {1} Enter)' $FZF_TMUX_OPTS
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

define init-pwndbg
  source ~/.pwndbg/gdbinit.py
  set show-tips off
  set context-sections disasm code backtrace
  set context-code-lines 16
  set context-backtrace-lines 4
  set banner-color white
  set memory-heap-color white
end

source ~/.gdbinit.py

init-gef
