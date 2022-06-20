set encoding=utf-8
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2
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
set showmatch
set matchtime=1
set number
set cursorline
set cursorlineopt=number
set termguicolors
set clipboard+=unnamedplus
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
  Plug 'vim-scripts/gtags.vim'
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

autocmd FileType c,cc,cpp,h,hpp nnoremap gtj <cmd>GtagsCursor<cr>
autocmd FileType c,cc,cpp,h,hpp nnoremap gtk <cmd>Gtags -r<cr><cr>
autocmd FileType c,cc,cpp,h,hpp nnoremap gth <cmd>Gtags -f %<cr>




"""""""""""""""""""""""""
"""""""" GITLINK """"""""
"""""""""""""""""""""""""

function! s:gitlink_normalize_url(url) abort
  let s:url = a:url
  let s:url = substitute(s:url, '^git@github.com:\(.\{-}\).git$', 'https://github.com/\1', '')
  let s:url = substitute(s:url, '^https://github.com/\(.\{-}\)/\(.\{-}\).git$', 'https://github.com/\1/\2', '')
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
  let s:pattern = printf('%s/blob/\(\x\+\)/\([^#]*\)\(#L\(\d\+\)\)\?', s:url)
  let s:params = matchlist(getline('.'), s:pattern)
  if s:params == []
    echo 'URL Error'
    return
  endif

  let s:hash = s:params[1]
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

  if s:hash != s:current_hash
    let s:message = printf('git checkout %s', s:hash)
    if confirm(s:message, "&Yes\n&No", 1) == 1
      echo system(printf('git checkout %s', s:hash))
      if v:shell_error != 0
        echo 'Git Error'
        return
      endif
    else
      return
    endif
  endif

  execute printf(':edit +%d %s', s:firstline, s:path)
endfunction

command! -range GitLinkCreate <line1>,<line2>call s:gitlink_create()
command! GitLinkJump call s:gitlink_jump()
nnoremap <C-l> <cmd>GitLinkCreate<cr>
nnoremap <C-m> <cmd>GitLinkJump<cr>
vnoremap <C-l> :GitLinkCreate<cr>
