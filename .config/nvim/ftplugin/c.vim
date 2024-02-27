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
  let l:command = printf("weggli %s %s", shellescape(a:pattern), shellescape(expand("%:p")))
  echo system(l:command)
endfunction

function GHSearchCode(keyword) abort
  let l:command = printf("gh search code --language c %s | column -t -l 2 -o ' | '", shellescape(a:keyword))
  echo system(l:command)
endfunction

function Complexity() abort
  let l:command = printf("complexity -t 0 %s", shellescape(expand("%:p")))
  echo system(l:command)
endfunction

function BugSpots() abort
  echo system("git bugspots")
endfunction

command -nargs=* Record :call Record(<q-args>)
noremap r :call ReplayBreakLine()<cr>
noremap R :call Replay()<cr>
command -nargs=* Weggli :call Weggli(<q-args>)
command SearchCode :call GHSearchCode(expand("<cword>"))
command Complexity :call Complexity()
command BugSpots :call BugSpots()

call GitNotesInit()
