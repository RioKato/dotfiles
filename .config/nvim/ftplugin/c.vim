function Record(command) abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("rr record %s", a:command)
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

function Weggli(pattern) abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("weggli %s %s | less", shellescape(a:pattern), shellescape(expand("%:p")))
  call system(["tmux", "split", "-h", l:command])
endfunction

command -nargs=* Record :call Record(<q-args>)
noremap r :call ReplayBreakLine()<cr>
noremap R :call Replay()<cr>
command -nargs=* Weggli :call Weggli(<q-args>)
call GitNotesInit()
