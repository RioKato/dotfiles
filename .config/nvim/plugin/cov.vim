highlight CovSignHighlight cterm=bold ctermfg=167 gui=bold guifg=#cd5c5c
sign define CovSign linehl=CovSignHighlight

function! CovSign(lcov)
  let l:i = 1
  let l:end = line("$")
  while l:i <= l:end
    execute printf("sign place %s line=%s name=CovSign group=CovSign", l:i, l:i)
    let l:i = l:i + 1
  endwhile

  for l:line in a:lcov
    let l:da = matchlist(l:line, 'DA:\(\d\+\),\(\d\+\)')
    if l:da != [] && str2nr(l:da[2], 10) > 0
      execute printf("sign unplace %d group=CovSign", str2nr(l:da[1], 10))
    endif
  endfor
endfunction

function! LLVMCov(program) abort
  let l:command = "rm -f default.profdata && llvm-profdata merge -o default.profdata default.profraw"
  call system(l:command)
  let l:command = printf("llvm-cov export -instr-profile=default.profdata %s -format=lcov -sources %s", a:program, expand("%:p"))
  call CovSign(systemlist(l:command))
endfunction

function! LCovRun() abort
  let l:command = printf("lcov -c -d . > lcov.out")
  call system(l:command)
endfunction

function! LCov() abort
  if !filereadable("lcov.out")
    call LCovRun()
  endif

  let l:command = printf("SF:%s", expand("%:p"))
  let l:command = printf("awk -v start=%s -v end='end_of_record' '$0==start,$0==end {print $1}' lcov.out", l:command)
  call CovSign(systemlist(l:command))
endfunction

command -nargs=1 LLVMCov :call LLVMCov(<f-args>)
command LCovRun :call LCovRun()
command LCov :call LCov()
