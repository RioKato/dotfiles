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
set relativenumber
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
autocmd FileType python nnoremap <buffer> <F9> :exec '!python3' shellescape(expand(@%), 1)<cr>
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

function! s:github_link() range
  let s:url = trim(system('git ls-remote --get-url origin'))
  let s:hash = trim(system('git rev-list -1 HEAD -- ' . shellescape(expand('%'), 1)))
  let s:path = trim(system('git ls-files --full-name ' . shellescape(expand('%'), 1)))
  let s:link = s:url . '/blob/' . s:hash . '/' . s:path . '#L' . a:firstline

  if a:firstline != a:lastline
    let s:link = s:link . '-L'. a:lastline
  endif

  if s:link =~ '^git@github.com:'
    let s:link = substitute(s:link, '^git@github.com:\(.*\).git', 'https://github.com/\1', '')
  elseif s:link =~ '^https://github.com/'
    let s:link = substitute(s:link, '^https://github.com/\(.*\)/\(.*\).git', 'https://github.com/\1/\2', '')
  endif

  echo s:link
  let @+ = s:link
endfunction

command! -range GithubLink <line1>,<line2>call s:github_link()
nnoremap <C-l> <cmd>GithubLink<cr>
vnoremap <C-l> :GithubLink<cr>

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
