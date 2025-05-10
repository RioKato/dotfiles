function RunGo()
  let l:command = 'go run "$(dirname $(go env GOMOD))/main.go"'
  write
  call RunTmux('go', command)
endfunction

noremap r :call RunGo()<cr>
