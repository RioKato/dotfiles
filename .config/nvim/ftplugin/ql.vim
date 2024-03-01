function CodeQL(database) abort
  let l:command = printf("tmux split -h codeql query run -d %s %s", shellescape(a:database), shellescape(expand("%:p")))
  call system(l:command)
endfunction

command -nargs=1 CodeQL :call CodeQL(<q-args>)
