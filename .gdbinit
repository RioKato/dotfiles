set auto-load safe-path /
set disassembly-flavor intel
set disable-randomization on
set follow-fork-mode parent
set pagination off
set logging file gdb.log
set confirm off
set print pretty on
set print demangle
set print asm-demangle
set style enabled off
handle SIGALRM ignore

set debuginfod enabled on
source ~/.gef.py
gef config context.layout "code source trace"
gef config context.nb_lines_code 18
gef config context.nb_lines_backtrace 4
gef config context.peek_calls False
gef config theme.registers_register_name "white"
gef config theme.dereference_register_value "white"
