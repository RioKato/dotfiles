function PyRun()
  if empty($TMUX)
    echo 'ERROR: run inside a tmux session'
  endif

  write
  call system(printf('ID=$(tmux new-window -P python3 %s) && tmux set -w -t $ID remain-on-exit failed', shellescape(@%, 1)))
endfunction

command! PyRun call PyRun()
noremap r :PyRun<cr>
