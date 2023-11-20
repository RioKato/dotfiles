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

define init-debuginfod
  set debuginfod enabled on
end

define init-gef
  source ~/.gef.py
  gef config context.layout "code source trace"
  gef config context.nb_lines_code 18
  gef config context.nb_lines_backtrace 4
  gef config context.peek_calls False
  gef config theme.registers_register_name "white"
  gef config theme.dereference_register_value "white"
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

define compile-load-decs
  shell touch $arg0
  shell gcc -g -fno-eliminate-unused-debug-types -x c -c -o $arg1 $arg0
  add-symbol-file $arg1
end

init-debuginfod
init-gef
