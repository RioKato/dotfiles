highlight CovSignHighlight cterm=bold ctermfg=167 gui=bold guifg=#cd5c5c
sign define CovSign numhl=CovSignHighlight

function! CovSign(lcov)
  execute printf("sign unplace * group=CovSign buffer=%d", bufnr("%"))

  for l:line in a:lcov
    let l:da = matchlist(l:line, 'DA:\(\d\+\),\(\d\+\)')
    if l:da != [] && str2nr(l:da[2], 10) > 0
      execute printf("sign place %s line=%s name=CovSign group=CovSign", l:da[1], l:da[1])
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

command -nargs=1 LLVMCov :call LLVMCov(<f-args>)
command LCov :call LCov()
