set encoding=utf-8
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2
set nowrap
set noswapfile
set nobackup
set noundofile
set autoread
set wildmenu
set gdefault
set ignorecase
set smartcase
set wrapscan
set incsearch
set hlsearch
set hidden
set virtualedit=block
set completeopt=menu,menuone,noselect
set tags=./tags;$HOME
set showmatch
set matchtime=1
set number
set cursorline
set cursorlineopt=number
set termguicolors
set clipboard+=unnamedplus
set pastetoggle=<F3>
set splitright
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap Y y$
nnoremap x "_x
nnoremap <esc><esc> <cmd>nohlsearch<cr>
nnoremap <C-w>z <C-w>\|<C-w>_
nnoremap <C-w>o <nop>
nnoremap <C-w><C-o> <nop>
xnoremap = "*c<C-r>=printf('0x%x', eval(@*))<cr><esc>
tnoremap <esc> <C-\><C-n>
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd FileType make setlocal noexpandtab
autocmd FileType markdown setlocal noexpandtab
autocmd FileType python nnoremap <buffer> <F9> :exec '!python3' shellescape(@%, 1)<cr>
autocmd Colorscheme * highlight Normal ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight NonText ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Folded ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight EndOfBuffer ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Visual ctermbg=Grey guibg=Grey
autocmd Colorscheme * highlight LineNr ctermbg=NONE guibg=NONE ctermfg=Grey guifg=Grey
autocmd Colorscheme * highlight MatchParen ctermbg=Grey guibg=Grey cterm=reverse,bold gui=reverse,bold

if has('win32') || has('win64')
  let g:python3_host_prog='python'
  tnoremap <C-p> <up>
  tnoremap <C-n> <down>
  tnoremap <C-f> <right>
  tnoremap <C-b> <left>
  tnoremap <C-a> <home>
  tnoremap <C-e> <end>
  tnoremap <C-h> <bs>
  tnoremap <C-d> <del>
endif


call plug#begin()
  Plug 'wbthomason/packer.nvim', { 'dir' : '~/.local/share/nvim/site/pack/packer/start/packer.nvim' }
  Plug 'mhartington/oceanic-next'
  Plug 'deris/vim-shot-f'
  Plug 't9md/vim-quickhl'
  Plug 'junegunn/vim-easy-align'
  Plug 'machakann/vim-sandwich'
  Plug 'tpope/vim-commentary'
  Plug 'rhysd/git-messenger.vim'
  Plug 'voldikss/vim-translator'
  Plug 'liuchengxu/graphviz.vim'
  Plug 'tyru/capture.vim'
  Plug 'dhruvasagar/vim-table-mode'
  Plug 'skanehira/denops-silicon.vim'
  Plug 'vim-denops/denops.vim'
call plug#end()


lua require('init')

syntax on
colorscheme OceanicNext

nmap <C-t> <plug>(quickhl-manual-this)
xmap <C-t> <plug>(quickhl-manual-this)
nmap <space>m <plug>(quickhl-manual-reset)
xmap <space>m <plug>(quickhl-manual-reset)

nmap ga <plug>(EasyAlign)
xmap ga <plug>(EasyAlign)

let g:git_messenger_no_default_mappings=1
nmap <C-g> <plug>(git-messenger)

let g:translator_target_lang='ja'

let g:graphviz_output_format='jpg'

autocmd FileType markdown :TableModeToggle

let g:silicon_options = {
      \  'font': 'Cica',
      \  'no_line_number': v:true,
      \  'no_round_corner': v:true,
      \  'no_window_controls': v:true,
      \  'background_color': '#aaaaff',
      \  'line_offset': 1,
      \  'line_pad': 2,
      \  'pad_horiz': 0,
      \  'pad_vert': 0,
      \  'shadow_blur_radius': 0,
      \  'shadow_color': '#555555',
      \  'shadow_offset_x': 0,
      \  'shadow_offset_y': 0,
      \  'tab_width': 4,
      \  'theme': 'GitHub',
      \ }

"""""""""""""""""""""""""
"""""""" GITLINK """"""""
"""""""""""""""""""""""""

function! s:gitlink_normalize_url(url) abort
  let s:url = a:url
  let s:url = substitute(s:url, '^git@github.com:\(.\{-}\).git$', 'https://github.com/\1', '')
  let s:url = substitute(s:url, '^https://github.com/\(.\{-}\)/\(.\{-}\).git$', 'https://github.com/\1/\2', '')
  let s:url = substitute(s:url, '^https://chromium.googlesource.com/v8/v8.git$', 'https://github.com/v8/v8', '')
  let s:url = substitute(s:url, '^https://sourceware.org/git/glibc.git$', 'https://github.com/bminor/glibc', '')
  let s:url = substitute(s:url, '^https://gitlab.freedesktop.org/polkit/polkit.git$', 'https://gitlab.freedesktop.org/polkit/polkit', '')
  let s:url = substitute(s:url, '^origin$', 'https://origin', '')

  return s:url
endfunction

function! s:gitlink_create() range abort
  let s:url = trim(system('git ls-remote --get-url origin'))
  if v:shell_error != 0
    echo 'Git Error'
    return
  endif

  let s:url = s:gitlink_normalize_url(s:url)
  let s:hash = trim(system(printf('git rev-list -1 HEAD -- %s', shellescape(@%, 1))))
  if v:shell_error != 0 || s:hash == ''
    echo 'Git Error'
    return
  endif

  let s:path = trim(system(printf('git ls-files --full-name %s', shellescape(@%, 1))))
  if v:shell_error != 0
    echo 'Git Error'
    return
  endif

  if a:firstline == a:lastline
    let s:link = printf('%s/blob/%s/%s#L%d', s:url, s:hash, s:path, a:firstline)
  else
    let s:link = printf('%s/blob/%s/%s#L%d-L%d', s:url, s:hash, s:path, a:firstline, a:lastline)
  endif

  let @+ = s:link
  echo s:link
endfunction

function! s:gitlink_jump() abort
  let s:url = trim(system('git ls-remote --get-url origin'))
  if v:shell_error != 0
    echo 'Git Error'
    return
  endif

  let s:url = s:gitlink_normalize_url(s:url)
  let s:pattern = printf('%s/blob/\(\x\+\)/\([A-Za-z0-9+\-_\.\~/]\+\)\(#L\(\d\+\)\)\?', s:url)
  let s:params = matchlist(getline('.'), s:pattern)
  if s:params == []
    echo 'URL Error'
    return
  endif

  let s:target_hash = s:params[1]
  let s:path = s:params[2]
  let s:firstline = s:params[4]
  let s:firstline = str2nr(s:firstline)

  let s:root = trim(system('git rev-parse --show-toplevel'))
  if v:shell_error != 0
    echo 'Git Error'
    return
  endif

  let s:path = printf('%s/%s', s:root, s:path)
  let s:current_hash = trim(system(printf('git rev-list -1 HEAD -- %s', shellescape(s:path, 1))))
  if v:shell_error != 0 || s:current_hash == ''
    echo 'Git Error'
    return
  endif

  if s:target_hash != s:current_hash
    let s:message = printf('git checkout %s', s:target_hash)
    if confirm(s:message, "&Yes\n&No", 1) == 1
      echo system(printf('git checkout %s', s:target_hash))
      if v:shell_error != 0
        echo 'Git Error'
        return
      endif
    else
      return
    endif
  endif

  if winnr('l') == 1
    execute printf(':vsplit +%d %s', s:firstline, s:path)
  else
    execute ':wincmd l'
    execute printf(':edit +%d %s', s:firstline, s:path)
  endif
endfunction

command! -range GitLinkCreate <line1>,<line2>call s:gitlink_create()
command! GitLinkJump call s:gitlink_jump()
nnoremap <C-l> <cmd>GitLinkCreate<cr>
nnoremap <C-n> <cmd>GitLinkJump<cr>
vnoremap <C-l> :GitLinkCreate<cr>
