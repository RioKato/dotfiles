function RunPython()
  let l:command = printf("python3 %s", shellescape(@%, 1))
  write
  call RunTmux('python', command)
endfunction

noremap r :call RunPython()<cr>
