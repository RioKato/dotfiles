function! Record() abort
  let l:command = printf("tmux split -h rr record %s", input("rr record "))
  call system(l:command)
endfunction

function! Replay() abort
  let l:file = expand('%:p')
  let l:line = line(".")
  let l:command = printf("tmux send 'break %s:%d' Enter 'continue' Enter", l:file, l:line)
  call system("tmux split -h rr replay")
  sleep 1
  call system(l:command)
endfunction

noremap r :call Replay()<cr>
noremap R :call Record()<cr>


