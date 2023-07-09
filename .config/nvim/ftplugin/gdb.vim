function RunGdb()
  let l:command = printf("gdb -x %s", shellescape(@%, 1))
  write
  call RunTmux('gdb', command)
endfunction

function RunRr()
  let l:command = printf("rr replay -x %s", shellescape(@%, 1))
  write
  call RunTmux('gdb', command)
endfunction

noremap r :call RunGdb()<cr>
noremap R :call RunRr()<cr>
