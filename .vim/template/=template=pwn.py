#!/usr/bin/env python3

from pwn import *

context.binary    = ''
# context.arch      = 'amd64'
context.terminal  = ['tmux', 'splitw', '-h']
context.log_level = 'debug'

con = process([''], env={})
# con = remote('', 80)

elf = ELF('')

# EXAMPLES
# elf.bss()
# elf.plt.fun
# elf.got.fun
# elf.address = 0xdeadbeef
# flat(0xdeadbeef, 0xdeadbeef, ...)
# gdb.attach(con)
# constants.SYS_execv

con.interactive()
