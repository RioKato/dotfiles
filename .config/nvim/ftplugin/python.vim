function PyRun()
  if empty($TMUX)
    echo 'ERROR: Must be run inside a tmux session'
  endif

  call system(printf('tmux new-window python3 %s', shellescape(@%, 1)))
endfunction

command! Run call PyRun()
