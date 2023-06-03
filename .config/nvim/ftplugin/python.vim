function PyRun()
  if empty($TMUX)
    echo 'ERROR: must be run inside a tmux session'
  endif

  write
  call system(printf('tmux new-window python3 %s', shellescape(@%, 1)))
endfunction

command! Run call PyRun()
