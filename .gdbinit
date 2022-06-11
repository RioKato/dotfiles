set auto-load safe-path /
set disassembly-flavor intel
set disable-randomization on
set follow-fork-mode parent
set pagination off
set logging file gdb.log
set logging on
set print pretty on
set print demangle
set print asm-demangle
directory ./glibc

source ~/.gef.py
