function RunCargoCheck()
  let l:command = "cargo check"
  write
  call RunTmux('cargo', command)
endfunction

function RunCargoRun()
  let l:command = "cargo run"
  write
  call RunTmux('cargo', command)
endfunction

noremap r :call RunCargoCheck()<cr>
noremap R :call RunCargoRun()<cr>
