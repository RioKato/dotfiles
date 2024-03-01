function CodeQL(database) abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("tmux split -h codeql query run -d %s %s", shellescape(a:database), shellescape(expand("%:p")))
  call system(l:command)
endfunction

command -nargs=* CodeQL :call CodeQL(<q-args>)
