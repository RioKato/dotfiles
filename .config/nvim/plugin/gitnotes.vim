function GitNotesBufWriteCmd(bufnr) abort
  call execute(printf("write !git notes add -f -F - %s", bufname(bufnr("%"))))
  setlocal nomodified
  call GitNotesUpdateSign(a:bufnr)
endfunction

function GitNotes() abort
  let l:bufnr = bufnr("%")
  let l:result = system(printf("git blame -L %d,+1 -l %s", line("."), expand("%:p")))
  let l:githash = split(l:result)[0]

  if buflisted(l:githash)
    vnew
    execute printf("buffer %s", l:githash)
    return
  endif

  if bufexists(l:githash)
    execute printf("bwipeout %s", l:githash)
  endif

  vnew
  let l:result = system(printf("git notes show %s", l:githash))
  if v:shell_error == 0
    put =l:result
  endif
  setlocal buftype=acwrite
  setlocal filetype=markdown
  setlocal nomodified
  execute printf("file %s", l:githash)
  execute printf("autocmd BufWriteCmd %s call GitNotesBufWriteCmd(%d)", l:githash, l:bufnr)
endfunction

sign define GitNotesSign text=N

function GitNotesUpdateSign(bufnr) abort
  let l:result = systemlist(printf("git notes"))
  let l:notes = []

  for l:line in l:result
    let l:notes = add(l:notes, split(l:line)[1])
  endfor

  let l:result = systemlist(printf("git blame -l %s", bufname(a:bufnr)))
  let l:count = 1
  for l:line in l:result
    execute printf("sign unplace %d group=GitNotesSign buffer=%d", l:count, a:bufnr)

    let l:githash = split(l:line)[0]
    if index(l:notes, l:githash) >= 0
      execute printf("sign place %d line=%d name=GitNotesSign buffer=%d", l:count, l:count, a:bufnr)
    endif

    let l:count += 1
  endfor
endfunction
