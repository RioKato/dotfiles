function Record() abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("rr record d8 %s", expand("%:p"))
  call system(["tmux", "split", "-h", l:command])
endfunction

function Replay() abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = "rr replay"
  call system(["tmux", "split", "-h", l:command])
endfunction

function ReplayBreakLine() abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("break %s:%d", expand("%:p"), line("."))
  let l:command = printf("rr replay -- -ex %s -ex continue", shellescape(l:command))
  call system(["tmux", "split", "-h", l:command])
endfunction

command Record :call Record()
noremap r :call ReplayBreakLine()<cr>
noremap R :call Replay()<cr>
