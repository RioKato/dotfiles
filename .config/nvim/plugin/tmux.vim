function RunTmux(window, command) abort
  if empty($TMUX)
    echoerr 'ERROR: run inside a tmux session'
  endif

  let l:command = printf("
        \ tmux if -t %s '[ #{window_zoomed_flag} -eq 1 ]' 'resize-pane -t %s -Z' && tmux respawn-window -k -t %s %s ||
        \ tmux new-window -b -n %s %s && tmux set -w -t %s remain-on-exit on",
        \ a:window, a:window, a:window, a:command, a:window, a:command, a:window)
  call system(command)
endfunction
