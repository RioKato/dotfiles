function RunNode()
  let l:command = printf("node %s", shellescape(@%, 1))
  write
  call RunTmux('node', command)
endfunction

function Record() abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("rr record d8 --allow-natives-syntax %s", expand("%:p"))
  call system(["tmux", "split", "-h", l:command])
endfunction

noremap r :call RunNode()<cr>
command Record :call Record()
