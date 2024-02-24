function! Record(command) abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("rr record %s", a:command)
  let l:command = printf("tmux split -h %s", shellescape(l:command))
  call system(l:command)
endfunction

function! Replay() abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  call system("tmux split -h rr replay")
endfunction

function! ReplayBreakLine() abort
  call Replay()
  sleep 1
  let l:command = printf("break %s:%d", expand("%:p"), line("."))
  let l:command = printf("tmux send %s Enter continue Enter", shellescape(l:command))
  call system(l:command)
endfunction

function GHSearchCode(keyword) abort
  let l:command = printf("gh search code --language c %s | column -t -l 2 -o ' | ' | less -S", a:keyword)
  let l:command = printf("tmux split -h %s", shellescape(l:command))
  call system(l:command)
endfunction

function! Complexity() abort
  let l:command = printf("complexity -t 0 %s", shellescape(expand("%:p")))
  echo system(l:command)
endfunction

command -nargs=* Record :call Record(<q-args>)
noremap r :call ReplayBreakLine()<cr>
noremap R :call Replay()<cr>
command SearchCode :call GHSearchCode(expand("<cword>"))
command Complexity :call Complexity()

call GitNotesInit()
