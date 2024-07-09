function RunPython()
  let l:ext = expand('%:e')

  if ext == "py"
    let l:command = printf("python3 %s", shellescape(@%, 1))
    write
    call RunTmux('python', command)
  elseif ext == "idapy"
    let l:command = printf("python3 ~/.idapro/plugins/idapy.py %s", shellescape(@%, 1))
    write
    call RunTmux('idapy', command)
  endif
endfunction

noremap r :call RunPython()<cr>
