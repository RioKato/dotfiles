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

function RustupDoc() abort
  call system("rustup doc --std")
endfunction

noremap r :call RunCargoCheck()<cr>
noremap R :call RunCargoRun()<cr>
command! Doc call RustupDoc()
