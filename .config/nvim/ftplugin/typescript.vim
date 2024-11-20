function Npm() abort
  let l:command = 'npm start'
  write
  call RunTmux('node', command)
endfunction

noremap r :call Npm()<cr>
