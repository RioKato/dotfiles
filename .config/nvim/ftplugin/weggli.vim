
function! s:weggli() range abort
  let s:lines = join(getline(a:firstline, a:lastline), '')
  let s:fname = printf('%s.out', expand('%:t'))
  let current = bufnr('%')
  execute printf(':e %s', s:fname)
  execute ':%d'
  execute printf(':read ! weggli %s .', shellescape(s:lines))
  execute printf(':%db', current)
endfunction

command! -range Weggli <line1>,<line2>call s:weggli()
vnoremap <C-w> :Weggli<cr>
