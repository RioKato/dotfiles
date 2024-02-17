function! Record() abort
  let l:command = printf("rr record %s", input("rr record "))
  enew
  call termopen(command)
  startinsert
endfunction

function! Replay() abort
  let l:file = expand('%:p')
  let l:line = line(".")
  let l:bp = printf("break %s:%d\n", l:file, l:line)
  let l:cont = "continue\n"
  vnew
  call termopen("rr replay")
  sleep 1
  call jobsend(b:terminal_job_id, l:bp)
  call jobsend(b:terminal_job_id, l:cont)
  startinsert
endfunction

noremap r :call Replay()<cr>
noremap R :call Record()<cr>


