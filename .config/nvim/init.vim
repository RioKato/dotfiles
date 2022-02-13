set encoding=utf-8
set number
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
set virtualedit=block
set foldmethod=marker
set completeopt=menu,menuone,noselect
set cursorline
set cursorlineopt=number
set termguicolors
nnoremap j gj
nnoremap k gk
autocmd Colorscheme * highlight Normal ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight NonText ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight LineNr ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Folded ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight EndOfBuffer ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Visual ctermbg=Grey guibg=Grey
let g:loaded_matchparen=1


call plug#begin()
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'xiyaowong/nvim-cursorword'
  Plug 'ellisonleao/glow.nvim'
  Plug 'w0ng/vim-hybrid'
  Plug 'deris/vim-shot-f'
  Plug 't9md/vim-quickhl'
  Plug 'junegunn/vim-easy-align'
  Plug 'tpope/vim-commentary'
  Plug 'rhysd/git-messenger.vim'
  Plug 'voldikss/vim-translator'
  Plug 'aperezdc/vim-template'
  Plug 'liuchengxu/graphviz.vim'
  " Plug 'vim-scripts/gtags.vim'
call plug#end()


colorscheme hybrid

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

let g:templates_no_autocmd=1
let g:templates_directory='~/.vim/template'

" let g:Gtags_OpenQuickfixWindow = 0
" autocmd FileType c,cc,cpp,h,hpp nnoremap <C-j> <cmd>GtagsCursor<cr><cmd>Telescope quickfix<cr>
" autocmd FileType c,cc,cpp,h,hpp nnoremap <C-k> <cmd>Gtags -r<cr><cr><cmd>Telescope quickfix<cr>
" autocmd FileType c,cc,cpp,h,hpp nnoremap <space>h <cmd>Gtags -f %<cr><cmd>Telescope quickfix<cr>


lua << EOF

vim.cmd [[ autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup = 'IncSearch', timeout = 200 } ]]

local telescope = require('telescope')

telescope.setup {
  defaults = {
    layout_config = {
      width = 0.99,
      height = 0.99
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case'
    }
  }
}

telescope.load_extension('fzf')

telescope_builtin = require('telescope.builtin')
local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<space>f', '<cmd>lua telescope_builtin.find_files()<cr>', opts)
vim.api.nvim_set_keymap('n', '<space>b', '<cmd>lua telescope_builtin.buffers()<cr>', opts)
vim.api.nvim_set_keymap('n', '<space>r', '<cmd>lua telescope_builtin.registers()<cr>', opts)
vim.api.nvim_set_keymap('n', '<space>g', '<cmd>lua telescope_builtin.live_grep()<cr>', opts)
vim.api.nvim_set_keymap('n', '<space>c', '<cmd>lua telescope_builtin.git_commits()<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-s>', '<cmd>lua telescope_builtin.grep_string()<cr>', opts)

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-j>', '<cmd>lua telescope_builtin.lsp_definitions()<cr>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua telescope_builtin.lsp_references()<cr>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-h>', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>h', '<cmd>lua telescope_builtin.lsp_document_symbols()<cr>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space><space>', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<cr>'] = cmp.mapping.confirm({ select = true }),
    ['<tab>'] = cmp.mapping.confirm({ select = true })
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }
  })
})

local nvim_lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

nvim_lsp.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'c', 'cc', 'cpp' }
}

nvim_lsp.pylsp.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

-- nvim_lsp.pyright.setup {
--   on_attach = on_attach,
--   capabilities = capabilities
-- }

-- nvim_lsp.rust_analyzer.setup {
--   on_attach = on_attach,
--   capabilities = capabilities
-- }

EOF
