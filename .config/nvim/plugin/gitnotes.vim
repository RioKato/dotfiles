function GitNotesBufWriteCmd(bufnr) abort
  let l:bufname = bufname(bufnr("%"))
  let l:contents = join(getline(1, "$"), "\n")
  if l:contents == ""
    call system(printf("git notes remove %s", l:bufname))
  else
    call system(printf("git notes add -f -F - %s", l:bufname), l:contents)
  endif

  setlocal nomodified
  call GitNotesUpdateSign(a:bufnr)
endfunction

function GitNotes() abort
  let l:bufnr = bufnr("%")
  let l:result = system(printf("git blame -L %d,+1 -l %s", line("."), expand("%:p")))
  let l:hash = split(l:result)[0]
  let l:link = GitLinkCreate(l:hash)
  let l:link = printf("- [%s:%d](%s)", expand("%:t"), line("."), l:link)

  if l:hash == "0000000000000000000000000000000000000000"
    echo "not commited"
    return
  endif

  if buflisted(l:hash)
    vnew
    execute printf("buffer %s", l:hash)
    call append(line("$"), [l:link])
    return
  endif

  if bufexists(l:hash)
    execute printf("bwipeout %s", l:hash)
  endif

  vnew

  let l:result = systemlist(printf("git notes show %s", l:hash))
  if v:shell_error == 0
    call append(line("$") - 1, l:result)
    call append(line("$"), [l:link])
  else
    call append(line("$") - 1, [l:link])
  endif

  setlocal buftype=acwrite
  setlocal filetype=markdown
  setlocal nomodified
  execute printf("file %s", l:hash)
  execute printf("autocmd BufWriteCmd %s call GitNotesBufWriteCmd(%d)", l:hash, l:bufnr)
endfunction

sign define GitNotesSign text=N

function GitNotesUpdateSign(bufnr) abort
  let l:result = systemlist(printf("git notes"))
  let l:notes = []

  for l:line in l:result
    let l:notes = add(l:notes, split(l:line)[1])
  endfor

  execute printf("sign unplace * group=GitNotesSign buffer=%d", a:bufnr)

  let l:result = systemlist(printf("git blame -l %s", bufname(a:bufnr)))
  let l:count = 0
  for l:line in l:result
    let l:count += 1

    let l:hash = split(l:line)[0]
    if l:hash == "0000000000000000000000000000000000000000"
      continue
    endif

    if index(l:notes, l:hash) >= 0
      execute printf("sign place %d line=%d name=GitNotesSign group=GitNotesSign buffer=%d", l:count, l:count, a:bufnr)
    endif
  endfor
endfunction

function GitNotesHook() abort
  call system("git rev-parse")
  if v:shell_error == 0
    noremap <C-l> :call GitNotes()<cr>
  end
endfunction

function GitLinkNormalize(url) abort
  let l:url = a:url
  let l:url = substitute(l:url, '^git@github.com:\(.\{-}\).git$', 'https://github.com/\1', '')
  let l:url = substitute(l:url, '^https://github.com/\(.\{-}\)/\(.\{-}\).git$', 'https://github.com/\1/\2', '')
  return l:url
endfunction

function GitLinkCreate(hash) abort
  let l:url = trim(system('git ls-remote --get-url origin'))
  let l:url = GitLinkNormalize(l:url)
  let l:path = trim(system(printf("git ls-files --full-name %s", shellescape(@%, 1))))
  let l:line = line(".")
  let l:link = printf('%s/blob/%s/%s#L%d', l:url, a:hash, l:path, l:line)
  return l:link
endfunction
