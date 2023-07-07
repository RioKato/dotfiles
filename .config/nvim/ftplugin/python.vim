function PyRun()
  if empty($TMUX)
    echo 'ERROR: run inside a tmux session'
  endif

  write
  let l:command = printf("python3 %s", shellescape(@%, 1))
  let l:command = printf("tmux respawn-window -k -t python %s ||
        \ tmux new-window -bP -n python %s &&
        \ tmux set -w -t python remain-on-exit on",
        \ command, command)
  call system(command)
endfunction

command! PyRun call PyRun()
noremap r :PyRun<cr>
