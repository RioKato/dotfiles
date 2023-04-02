" for training
map h <nop>
map l <nop>

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
nnoremap <C-w>o <nop>
nnoremap <C-w><C-o> <nop>
inoremap <C-d> <del>
tnoremap <esc> <C-\><C-n>
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd BufNewFile,BufRead *.weg set filetype=weggli
autocmd FileType make setlocal noexpandtab
autocmd FileType markdown setlocal noexpandtab
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
  Plug 't9md/vim-quickhl'
  Plug 'junegunn/vim-easy-align'
  Plug 'machakann/vim-sandwich'
  Plug 'tpope/vim-commentary'
  Plug 'rhysd/git-messenger.vim'
  Plug 'voldikss/vim-translator'
  Plug 'liuchengxu/graphviz.vim'
  Plug 'tyru/capture.vim'
  Plug 'dhruvasagar/vim-table-mode'
  " Plug 'skanehira/denops-silicon.vim'
  " Plug 'vim-denops/denops.vim'
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
