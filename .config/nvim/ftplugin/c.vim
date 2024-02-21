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

function! LLVMCov(program) abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = "rm -f default.profdata && llvm-profdata merge -o default.profdata default.profraw"
  call system(l:command)
  let l:command = printf("llvm-cov show -instr-profile=default.profdata %s -sources %s --use-color | less -R -j %d", a:program, expand("%:p"), line("."))
  let l:command = printf("tmux split -h %s", shellescape(l:command))
  call system(l:command)
endfunction

command -nargs=* Record :call Record(<q-args>)
noremap r :call ReplayBreakLine()<cr>
noremap R :call Replay()<cr>
command -nargs=1 Cov :call LLVMCov(<f-args>)

call GitNotesInit()
