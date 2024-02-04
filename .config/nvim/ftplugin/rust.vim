function RunCargoBuild()
  let l:command = "cargo build"
  write
  call RunTmux('cargo', command)
endfunction

function RunCargoRun()
  let l:command = "cargo run"
  write
  call RunTmux('cargo', command)
endfunction

noremap r :call RunCargoBuild()<cr>
noremap R :call RunCargoRun()<cr>
