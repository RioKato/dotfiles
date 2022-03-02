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
set virtualedit=block
set completeopt=menu,menuone,noselect
set showmatch
set matchtime=1
set foldmethod=marker
set number
set cursorline
set cursorlineopt=number
set termguicolors
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
autocmd Colorscheme * highlight Normal ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight NonText ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight LineNr ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Folded ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight EndOfBuffer ctermbg=NONE guibg=NONE
autocmd Colorscheme * highlight Visual ctermbg=Grey guibg=Grey
autocmd Colorscheme * highlight MatchParen ctermbg=Grey guibg=Grey cterm=reverse,bold gui=reverse,bold


call plug#begin()
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-vsnip'
  Plug 'hrsh7th/vim-vsnip'
  Plug 'xiyaowong/nvim-cursorword'
  Plug 'ellisonleao/glow.nvim'
  Plug 'w0ng/vim-hybrid'
  Plug 'deris/vim-shot-f'
  Plug 't9md/vim-quickhl'
  Plug 'junegunn/vim-easy-align'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'aperezdc/vim-template'
  Plug 'rhysd/git-messenger.vim'
  Plug 'voldikss/vim-translator'
  Plug 'liuchengxu/graphviz.vim'
  Plug 'vim-scripts/gtags.vim'
call plug#end()


colorscheme hybrid

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

let g:Gtags_OpenQuickfixWindow=0
autocmd FileType c,cc,cpp,h,hpp nnoremap g<C-j> <cmd>GtagsCursor<cr>
autocmd FileType c,cc,cpp,h,hpp nnoremap g<C-k> <cmd>Gtags -r<cr><cr><cmd>Telescope quickfix<cr>
autocmd FileType c,cc,cpp,h,hpp nnoremap g<space>h <cmd>Gtags -f %<cr><cmd>Telescope quickfix<cr>

lua << EOF

vim.o.jumpoptions = 'stack'
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
  }, {
    { name = 'buffer' }
  })
})

local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require('lspconfig')

lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

lspconfig.pylsp.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = vim.loop.cwd
}

-- lspconfig.pyright.setup {
--   on_attach = on_attach,
--   capabilities = capabilities
-- }

local nvim_treesitter = require('nvim-treesitter.configs')

nvim_treesitter.setup {
  highlight = {
    enable = true
  }
}

EOF
