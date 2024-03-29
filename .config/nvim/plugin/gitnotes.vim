function GitNotes() abort
  let l:bufnr = bufnr("%")
  let l:link = printf("- [%s:%d](%s)", expand("%:t"), line("."), GitLinkCreate())
  let l:hash = trim(system("git show --format='%H' --no-patch"))

  let l:winid = bufwinid(printf("^%s$", l:hash))
  if l:winid != -1
    call win_gotoid(l:winid)
    call append(line("."), [l:link])
    call cursor(line(".") + 1, 1)
    return
  endif

  if buflisted(l:hash)
    let l:winid = win_getid()
    vsplit
    execute printf("buffer %s", l:hash)
    call win_gotoid(l:winid)
    return

  else
    if bufexists(l:hash)
      execute printf("bwipeout %s", l:hash)
    endif

    let l:winid = win_getid()
    vnew
    setlocal buftype=acwrite
    setlocal filetype=markdown
    setlocal nomodified
    execute printf("file %s", l:hash)
    execute printf("autocmd BufWriteCmd %s call GitNotesBufWriteCmd()", l:hash)
    noremap <buffer> <C-l> :call GitLinkOpen()<cr>

    let l:result = systemlist(printf("git notes show %s", l:hash))
    if v:shell_error == 0
      call append(line("$") - 1, l:result)
      call cursor(1, 1)
    endif

    call win_gotoid(l:winid)
    return
  endif
endfunction

function GitNotesBufWriteCmd() abort
  let l:bufname = bufname(bufnr("%"))
  let l:contents = join(getline(1, "$"), "\n")
  if l:contents == ""
    call system(printf("git notes remove %s", l:bufname))
  else
    call system(printf("git notes add -f -F - %s", l:bufname), l:contents)
  endif

  setlocal nomodified
endfunction

function GitLinkNormalize(url) abort
  let l:url = a:url
  let l:url = substitute(l:url, '^git@github.com:\(.\{-}\).git$', 'https://github.com/\1', "")
  let l:url = substitute(l:url, '^https://github.com/\(.\{-}\)/\(.\{-}\).git$', 'https://github.com/\1/\2', "")
  return l:url
endfunction

function GitLinkCreate() abort
  let l:url = trim(system("git ls-remote --get-url origin"))
  let l:url = GitLinkNormalize(l:url)
  let l:hash = trim(system(printf('git rev-list -1 HEAD -- %s', shellescape(@%, 1))))
  let l:path = trim(system(printf("git ls-files --full-name %s", shellescape(@%, 1))))
  let l:line = line(".")
  let l:link = printf("%s/blob/%s/%s#L%d", l:url, l:hash, l:path, l:line)
  return l:link
endfunction

function GitLinkOpen() abort
  let l:url = trim(system("git ls-remote --get-url origin"))
  let l:url = GitLinkNormalize(l:url)
  let l:pattern = printf('%s/blob/\x\+/\([^#]\+\)#L\(\d\+\)', l:url)
  let l:params = matchlist(getline("."), l:pattern)
  if l:params == []
    echo "url error"
    return
  endif

  let l:path = l:params[1]
  let l:line = l:params[2]
  let l:root = trim(system("git rev-parse --show-toplevel"))
  let l:path = printf("%s/%s", l:root, l:path)

  let l:winid = bufwinid(printf("^%s$", l:path))
  if l:winid != -1
    call win_gotoid(l:winid)
    call cursor(l:line, 1)
    return
  endif

  let l:winid = win_getid()
  vsplit
  call win_gotoid(l:winid)
  execute printf("edit +%d %s", l:line, l:path)
endfunction

function GitNotesInit() abort
  call system("git rev-parse")
  if v:shell_error == 0
    noremap <buffer> <C-l> :call GitNotes()<cr>
  end
endfunction
