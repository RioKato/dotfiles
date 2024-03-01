function Record(command) abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("tmux split -h rr record %s", a:command)
  call system(l:command)
endfunction

function Replay() abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  call system("tmux split -h rr replay")
endfunction

function ReplayBreakLine() abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("break %s:%d", expand("%:p"), line("."))
  let l:command = printf("tmux split -h rr replay -- -ex %s -ex continue", shellescape(l:command))
  call system(l:command)
endfunction

function Weggli(pattern) abort
  let l:command = printf("tmux split -h weggli %s %s", shellescape(a:pattern), shellescape(expand("%:p")))
  call system(l:command)
endfunction

command -nargs=* Record :call Record(<q-args>)
noremap r :call ReplayBreakLine()<cr>
noremap R :call Replay()<cr>
command -nargs=* Weggli :call Weggli(<q-args>)
call GitNotesInit()
