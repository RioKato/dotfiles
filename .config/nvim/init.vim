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

" colorscheme desert
syntax on

lua require('init')
