function Record() abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("rr record d8 --allow-natives-syntax %s", expand("%:p"))
  call system(["tmux", "split", "-h", l:command])
endfunction

command Record :call Record()
