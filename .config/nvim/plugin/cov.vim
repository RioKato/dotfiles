sign define CovSign text=P texthl=Error

function! CovSign(lcov)
  execute printf("sign unplace * group=CovSign buffer=%d", bufnr("%"))

  for l:line in a:lcov
    let l:no = matchlist(l:line, 'DA:\(\d\+\),1')
    if l:no != []
      let l:no = l:no[1]
      execute printf("sign place %s line=%s name=CovSign group=CovSign", l:no, l:no)
    endif
  endfor
endfunction

function! LLVMCov(program) abort
  let l:command = "rm -f default.profdata && llvm-profdata merge -o default.profdata default.profraw"
  call system(l:command)
  let l:command = printf("llvm-cov export -instr-profile=default.profdata %s -format=lcov -sources %s", a:program, expand("%:p"))
  call CovSign(systemlist(l:command))
endfunction

function! LCov() abort
  let l:command = printf("SF:%s", expand("%:p"))
  let l:command = printf("lcov -c -d . 2> /dev/null | awk -v start=%s -v end='end_of_record' '$0==start,$0==end {print $1}'", l:command)
  call CovSign(systemlist(l:command))
endfunction

function! Cov(...) abort
  if filereadable("default.profraw")
    call LLVMCov(a:1)
  else
    call LCov()
  endif
endfunction

function CovInit() abort
  command -nargs=? Cov :call Cov(<q-args>)
endfunction
