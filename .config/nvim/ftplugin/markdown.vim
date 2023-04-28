setlocal noexpandtab

let g:vim_markdown_folding_disabled = 1
let g:previm_enable_realtime = 1
let g:mdip_imgdir = 'image'
let g:mdip_imgdir_intext = 'image'
nmap <buffer><silent> <leader>s :!xfce4-screenshooter -rc<cr>
nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<cr>
