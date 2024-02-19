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
  let l:file = trim(system(printf("git ls-files --full-name %s", shellescape(@%, 1))))
  let l:line = line(".")
  let l:bufnr = bufnr("%")
  let l:result = system(printf("git blame -L %d,+1 -l %s", line("."), expand("%:p")))
  let l:githash = split(l:result)[0]

  if l:githash == "0000000000000000000000000000000000000000"
    echo "not commited"
    return
  endif

  if buflisted(l:githash)
    vnew
    execute printf("buffer %s", l:githash)
    call append(line("$"), [printf("- %s:%d", l:file, l:line)])
    return
  endif

  if bufexists(l:githash)
    execute printf("bwipeout %s", l:githash)
  endif

  vnew

  let l:result = systemlist(printf("git notes show %s", l:githash))
  if v:shell_error == 0
    call append(line("$") - 1, l:result)
    call append(line("$"), [printf("- %s:%d", l:file, l:line)])
  else
    call append(line("$") - 1, [printf("- %s:%d", l:file, l:line)])
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

  execute printf("sign unplace * group=GitNotesSign buffer=%d", a:bufnr)

  let l:result = systemlist(printf("git blame -l %s", bufname(a:bufnr)))
  let l:count = 0
  for l:line in l:result
    let l:count += 1

    let l:githash = split(l:line)[0]
    if l:githash == "0000000000000000000000000000000000000000"
      continue
    endif

    if index(l:notes, l:githash) >= 0
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
