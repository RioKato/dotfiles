set encoding=utf-8
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2
set noswapfile
set nobackup
set noundofile
set wildmenu
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
autocmd Colorscheme * highlight Normal ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight NonText ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Folded ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight EndOfBuffer ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Visual ctermbg=Grey guibg=Grey
autocmd Colorscheme * highlight LineNr ctermbg=NONE guibg=NONE ctermfg=Grey guifg=Grey
autocmd Colorscheme * highlight MatchParen ctermbg=Grey guibg=Grey cterm=reverse,bold gui=reverse,bold


call plug#begin()
  Plug 'wbthomason/packer.nvim', { 'dir' : '~/.local/share/nvim/site/pack/packer/start/packer.nvim' }
  Plug 'mhartington/oceanic-next'
  Plug 'deris/vim-shot-f'
  Plug 'jiangmiao/auto-pairs'
  Plug 't9md/vim-quickhl'
  Plug 'junegunn/vim-easy-align'
  Plug 'machakann/vim-sandwich'
  Plug 'tpope/vim-commentary'
  Plug 'aperezdc/vim-template'
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

let g:templates_no_autocmd=1
let g:templates_directory='~/.vim/template'

let g:git_messenger_no_default_mappings=1
nmap <C-g> <plug>(git-messenger)

let g:translator_target_lang='ja'

let g:graphviz_output_format='jpg'

autocmd FileType c,cc,cpp,h,hpp nnoremap gtj <cmd>GtagsCursor<cr>
autocmd FileType c,cc,cpp,h,hpp nnoremap gtk <cmd>Gtags -r<cr><cr>
autocmd FileType c,cc,cpp,h,hpp nnoremap gth <cmd>Gtags -f %<cr>
