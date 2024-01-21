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


define record-breakpoints
  init-if-undefined $__record_breakpoints__ = 1

  if $__record_breakpoints__
    delete
    source breakpoints.gdb

    define hook-quit
      save breakpoints breakpoints.gdb
    end

    define e
      pipe info breakpoints | grep '^[0-9]' | fzf-tmux +m --bind 'enter:become(tmux send enable Space {1} Enter)' $FZF_TMUX_OPTS
    end

    define d
      pipe info breakpoints | grep '^[0-9]' | fzf-tmux +m --bind 'enter:become(tmux send disable Space {1} Enter)' $FZF_TMUX_OPTS
    end
  end

  set $__record_breakpoints__ = 0
end

define hookpost-run
  record-breakpoints
end

define hookpost-start
  record-breakpoints
end

define hookpost-attach
  record-breakpoints
end

define vim
  shell tmux split-window vim $arg0
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
