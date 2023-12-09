function RunGo()
  let l:command = printf("go run %s", shellescape(@%, 1))
  write
  call RunTmux('go', command)
endfunction

noremap r :call RunGo()<cr>
