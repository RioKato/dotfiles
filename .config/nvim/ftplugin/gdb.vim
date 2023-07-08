function RunGdb()
  let l:command = printf("gdb -x %s", shellescape(@%, 1))
  write
  call RunTmux('gdb', command)
endfunction

noremap r :call RunGdb()<cr>
