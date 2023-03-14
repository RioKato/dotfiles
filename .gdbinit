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
handle SIGALRM ignore

set debuginfod enabled on
source /usr/share/gef/gef.py
