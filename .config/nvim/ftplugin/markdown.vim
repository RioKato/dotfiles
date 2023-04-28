autocmd FileType markdown setlocal noexpandtab
let g:vim_markdown_folding_disabled = 1
let g:previm_enable_realtime = 1
autocmd FileType markdown nmap <buffer><silent> <leader>s :!xfce4-screenshooter -rc<CR>
autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
let g:mdip_imgdir = 'images'
