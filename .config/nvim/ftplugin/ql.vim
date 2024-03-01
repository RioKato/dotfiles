function CodeQL(database) abort
  if empty($TMUX)
    echoerr "ERROR: run inside a tmux session"
  endif

  let l:command = printf("codeql query run -d %s %s | less", shellescape(a:database), shellescape(expand("%:p")))
  call system(["tmux", "split", "-h", l:command])
endfunction

command -nargs=* CodeQL :call CodeQL(<q-args>)
