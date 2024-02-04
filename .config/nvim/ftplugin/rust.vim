function RunCargo()
  let l:command = "cargo build"
  write
  call RunTmux('cargo', command)
endfunction

noremap r :call RunCargo()<cr>
