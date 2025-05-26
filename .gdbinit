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


define S
  source breakpoints.gdb

  define S
    save breakpoints breakpoints.gdb
  end

  define hook-quit
    S
  end
end

define I
  shell gcc -g -fno-eliminate-unused-debug-types -x c -c -o /tmp/gdb $arg0
  add-symbol-file /tmp/gdb
  shell rm -f /tmp/gdb
end

define B
  pipe info breakpoints | grep '^[0-9]' | fzf-tmux +m +s --bind 'enter:become(echo -n {4} {1} > /tmp/gdb)' $FZF_TMUX_OPTS
  shell sed -ie 's/^y/disable/g;t;s/^n/enable/g' /tmp/gdb
  source /tmp/gdb
  shell rm -f /tmp/gdb
end

define init-gef
  source ~/.gef.py
  gef config theme.registers_register_name "white"
  gef config theme.dereference_register_value "white"
  gef config context.nb_lines_backtrace 4
  gef config context.nb_lines_code 5
  gef config gef.disable_target_remote_overwrite True
end

# init-gef
