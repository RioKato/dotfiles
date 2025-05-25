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
set showmatch
set matchtime=1
set number
set cursorline
set cursorlineopt=number
set termguicolors
set splitright
set mouse=
let g:loaded_matchparen = 1
autocmd Colorscheme * highlight Normal ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight NonText ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Folded ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight EndOfBuffer ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Visual ctermbg=Grey guibg=Grey
autocmd Colorscheme * highlight LineNr ctermbg=NONE guibg=NONE ctermfg=Grey guifg=Grey
autocmd Colorscheme * highlight MatchParen ctermbg=Grey guibg=Grey cterm=reverse,bold gui=reverse,bold
syntax on

lua require('init')
