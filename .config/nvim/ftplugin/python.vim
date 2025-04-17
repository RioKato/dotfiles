function RunPython()
  let l:command = printf("python3 %s", shellescape(@%, 1))
  write
  call RunTmux('python', command)
endfunction

function RunBinja()
  write
  call system('binja-runprev')
endfunction

noremap r :call RunPython()<cr>
command! RunBinja call RunBinja()
