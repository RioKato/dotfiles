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
set mouse=
let g:loaded_matchparen = 1
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap Y y$
nnoremap x "_x
nnoremap <esc><esc> <cmd>nohlsearch<cr>
nnoremap <C-w>z <C-w>\|<C-w>_
inoremap <C-d> <del>
tnoremap <esc> <C-\><C-n>
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd BufNewFile,BufRead *.gdb set filetype=gdb
autocmd Colorscheme * highlight Normal ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight NonText ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Folded ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight EndOfBuffer ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Visual ctermbg=Grey guibg=Grey
autocmd Colorscheme * highlight LineNr ctermbg=NONE guibg=NONE ctermfg=Grey guifg=Grey
autocmd Colorscheme * highlight MatchParen ctermbg=Grey guibg=Grey cterm=reverse,bold gui=reverse,bold

call plug#begin()
  Plug 'deris/vim-shot-f'
  Plug 't9md/vim-quickhl'
  Plug 'junegunn/vim-easy-align'
  Plug 'machakann/vim-sandwich'
  Plug 'tpope/vim-commentary'
  Plug 'voldikss/vim-translator'
  Plug 'liuchengxu/graphviz.vim'
  Plug 'tyru/open-browser.vim'
call plug#end()

lua require('init')

colorscheme desert
syntax on

nmap <C-t> <plug>(quickhl-manual-this)
xmap <C-t> <plug>(quickhl-manual-this)
nmap <space>m <plug>(quickhl-manual-reset)
xmap <space>m <plug>(quickhl-manual-reset)

nmap ga <plug>(EasyAlign)
xmap ga <plug>(EasyAlign)

let g:translator_target_lang='ja'
