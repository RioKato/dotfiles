if exists('g:loaded_gitlink')
  finish
endif
let g:loaded_gitlink = 1

function! s:gitlink_normalize_url(url) abort
  let s:url = a:url
  let s:url = substitute(s:url, '^git@github.com:\(.\{-}\).git$', 'https://github.com/\1', '')
  let s:url = substitute(s:url, '^https://github.com/\(.\{-}\)/\(.\{-}\).git$', 'https://github.com/\1/\2', '')
  let s:url = substitute(s:url, '^https://chromium.googlesource.com/v8/v8.git$', 'https://github.com/v8/v8', '')
  let s:url = substitute(s:url, '^https://sourceware.org/git/glibc.git$', 'https://github.com/bminor/glibc', '')
  let s:url = substitute(s:url, '^https://gitlab.freedesktop.org/polkit/polkit.git$', 'https://gitlab.freedesktop.org/polkit/polkit', '')
  let s:url = substitute(s:url, '^origin$', 'https://origin', '')

  return s:url
endfunction

function! s:gitlink_create() range abort
  let s:url = trim(system('git ls-remote --get-url origin'))
  if v:shell_error != 0
    echo 'Git Error'
    return
  endif

  let s:url = s:gitlink_normalize_url(s:url)
  let s:hash = trim(system(printf('git rev-list -1 HEAD -- %s', shellescape(@%, 1))))
  if v:shell_error != 0 || s:hash == ''
    echo 'Git Error'
    return
  endif

  let s:path = trim(system(printf('git ls-files --full-name %s', shellescape(@%, 1))))
  if v:shell_error != 0
    echo 'Git Error'
    return
  endif

  if a:firstline == a:lastline
    let s:link = printf('%s/blob/%s/%s#L%d', s:url, s:hash, s:path, a:firstline)
  else
    let s:link = printf('%s/blob/%s/%s#L%d-L%d', s:url, s:hash, s:path, a:firstline, a:lastline)
  endif

  let @+ = s:link
  echo s:link
endfunction

function! s:gitlink_jump() abort
  let s:url = trim(system('git ls-remote --get-url origin'))
  if v:shell_error != 0
    echo 'Git Error'
    return
  endif

  let s:url = s:gitlink_normalize_url(s:url)
  let s:pattern = printf('%s/blob/\(\x\+\)/\([A-Za-z0-9+\-_\.\~/]\+\)\(#L\(\d\+\)\)\?', s:url)
  let s:params = matchlist(getline('.'), s:pattern)
  if s:params == []
    echo 'URL Error'
    return
  endif

  let s:target_hash = s:params[1]
  let s:path = s:params[2]
  let s:firstline = s:params[4]
  let s:firstline = str2nr(s:firstline)

  let s:root = trim(system('git rev-parse --show-toplevel'))
  if v:shell_error != 0
    echo 'Git Error'
    return
  endif

  let s:path = printf('%s/%s', s:root, s:path)
  let s:current_hash = trim(system(printf('git rev-list -1 HEAD -- %s', shellescape(s:path, 1))))
  if v:shell_error != 0 || s:current_hash == ''
    echo 'Git Error'
    return
  endif

  if s:target_hash != s:current_hash
    let s:message = printf('git checkout %s', s:target_hash)
    if confirm(s:message, "&Yes\n&No", 1) == 1
      echo system(printf('git checkout %s', s:target_hash))
      if v:shell_error != 0
        echo 'Git Error'
        return
      endif
    else
      return
    endif
  endif

  if winnr('l') == 1
    execute printf(':vsplit +%d %s', s:firstline, s:path)
  else
    execute ':wincmd l'
    execute printf(':edit +%d %s', s:firstline, s:path)
  endif
endfunction

command! -range GitLinkCreate <line1>,<line2>call s:gitlink_create()
command! GitLinkJump call s:gitlink_jump()
nnoremap <C-l> <cmd>GitLinkCreate<cr>
nnoremap <C-n> <cmd>GitLinkJump<cr>
vnoremap <C-l> :GitLinkCreate<cr>
