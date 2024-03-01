highlight CovSignHighlight cterm=bold ctermfg=167 gui=bold guifg=#cd5c5c
sign define CovSign linehl=CovSignHighlight

function CovClear() abort
  execute printf("sign unplace * group=CovSign buffer=%d", bufnr("%"))
endfunction

function CovSign(lcov) abort
  call CovClear()

  for l:line in a:lcov
    let l:da = matchlist(l:line, 'DA:\(\d\+\),\(\d\+\)')
    if l:da != [] && str2nr(l:da[2], 10) == 0
      let l:no = str2nr(l:da[1], 10)
      execute printf("sign place %d line=%d name=CovSign group=CovSign", l:no, l:no)
    endif
  endfor
endfunction

function LLVMCovRun() abort
  call system("rm -f default.profdata && llvm-profdata merge -o default.profdata default.profraw")
endfunction

function LLVMCov(program) abort
  if !filereadable("default.profdata")
    call LLVMCovRun()
  endif

  let l:command = printf("llvm-cov export -instr-profile=default.profdata %s -format=lcov -sources %s", shellescape(a:program), shellescape(expand("%:p")))
  call CovSign(systemlist(l:command))
endfunction

function LCovRun() abort
  call system("lcov -c -d . -o lcov.out")
endfunction

function LCov() abort
  if !filereadable("lcov.out")
    call LCovRun()
  endif

  let l:command = printf("SF:%s", expand("%:p"))
  let l:command = printf("awk -v start=%s -v end='end_of_record' '$0==start,$0==end {print $1}' lcov.out", shellescape(l:command))
  call CovSign(systemlist(l:command))
endfunction

command LLVMCovRun :call LLVMCovRun()
command -nargs=1 LLVMCov :call LLVMCov(<f-args>)
command LCovRun :call LCovRun()
command LCov :call LCov()
command CovClear :call CovClear()
