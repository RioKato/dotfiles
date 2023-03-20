
function! s:weggli() range abort
  let s:lines = getline(a:firstline, a:lastline)
  execute printf(':!weggli -X \'%s\' .', lines)
endfunction
