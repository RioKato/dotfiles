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

sign define LLVMCovSign text=P texthl=Error

function! LLVMCov(program) abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = "rm -f default.profdata && llvm-profdata merge -o default.profdata default.profraw"
  call system(l:command)
  let l:command = printf("llvm-cov export -instr-profile=default.profdata %s -format=lcov -sources %s", a:program, expand("%:p"))
  let l:result = systemlist(l:command)
  execute printf("sign unplace * group=LLVMCovSign buffer=%d", bufnr("%"))

  for l:line in l:result
    let l:no = matchlist(l:line, 'DA:\(\d\+\),1')
    if l:no != []
      let l:no = l:no[1]
      execute printf("sign place %s line=%s name=LLVMCovSign group=LLVMCovSign", l:no, l:no)
    endif
  endfor
endfunction

function GHSearchCode(keyword) abort
  let l:command = printf("gh search code --language c %s | column -t -l 2 -o ' | ' | less -S", a:keyword)
  let l:command = printf("tmux split -h %s", shellescape(l:command))
  call system(l:command)
endfunction

command -nargs=* Record :call Record(<q-args>)
noremap r :call ReplayBreakLine()<cr>
noremap R :call Replay()<cr>
command -nargs=1 Cov :call LLVMCov(<f-args>)
command SearchCode :call GHSearchCode(expand("<cword>"))

call GitNotesInit()
