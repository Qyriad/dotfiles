scriptencoding utf-8

syntax on

" This will be enabled automatically after initialization scripts run
" enabling it early will load syntax definitions too soon
" syntax on
" filetype plugin indent on

lua << EOF
-- Bootstrap packer.nvim if necessary.
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.cmd [[echomsg "Installing packer.nvim"]]
	vim.fn.system {"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path }
	vim.cmd [[packadd packer.nvim]]
end

-- And initialize it.
packer = require("packer")
packer.init()
packer.reset()
packer.use "wbthomason/packer.nvim"
EOF

runtime ftplugin/man.vim

let $CONFIGPATH = stdpath('config')

source $CONFIGPATH/core.vim
source $CONFIGPATH/utils.vim
source $CONFIGPATH/syntax.vim
source $CONFIGPATH/highlight.vim
source $CONFIGPATH/lsp.vim
source $CONFIGPATH/statusline.vim


""" Other mappings.

" Copy to tmux.
vnoremap <leader>y :Tyank<CR>

" Easy-Align
xmap ga <Plug>(EasyAlign)


" PROBATION:
" Word motion makes `word` defined to be more like a variable segment
" I really never use Vim's definition of a `WORD`, so I'll replace its mappings to behave like Vim's original `word`s.
"nnoremap W w
"nnoremap E e
"nnoremap B b
"nnoremap gE ge
"xnoremap W w
"xnoremap E e
"xnoremap B b
"xnoremap gE ge
"onoremap W w
"onoremap E e
"onoremap B b
"onoremap gE ge

"xnoremap aW aw
"xnoremap iW iw

" Also a few <leader> mappings for the same thing, particularly for operator-pending mode
"onoremap <leader>w w
"onoremap <leader>iw iw
"onoremap i<leader>w iw
"onoremap <leader>aw aw
"onoremap a<leader>w aw


" Capitalize the last inserted text
function! Capitalize_and_return()
	normal `[v`]gU`]
	silent s/-/_/
	normal ``a
endfunction

" Usable from <C-o>
nnoremap <leader>c :normal `[v`]gU`]a<CR>
" Usable from insert mode, and replaces - with _
inoremap <F3> <C-o>:call Capitalize_and_return()<CR>


"let g:coc_global_extensions = ['coc-rust-analyzer', 'coc-jedi', 'coc-vimlsp', 'coc-json', 'coc-lists', 'coc-git']
"let g:coc_global_extensions = ['coc-rust-analyzer', 'coc-pyright', 'coc-vimlsp', 'coc-json', 'coc-lists', 'coc-git']

let g:ranger_map_keys = 0
nnoremap <leader>f :RangerCurrentDirectory<CR>


nnoremap ]g <Cmd>lua gitsigns.next_hunk({ preview = true })<CR>
nnoremap [g <Cmd>lua gitsigns.prev_hunk({ preview = true })<CR>
nnoremap gs <Cmd>lua gitsigns.preview_hunk()<CR>


lua << EOF
local use = require("packer").use
-- Text editing.
use 'tmhedberg/SimpylFold' -- Python folds.
use 'junegunn/vim-easy-align'

-- Utilities.
use 'tpope/vim-eunuch'
use 'ctrlpvim/ctrlp.vim'
use 'rbgrouleff/bclose.vim' -- Dependency for ranger.vim
use 'francoiscabrol/ranger.vim'
use 'tpope/vim-tbone' -- :Tyank and :Tput
use {
	'lewis6991/gitsigns.nvim',
	config = function()
		gitsigns = require("gitsigns")
		gitsigns.setup {}
	end,
}
use 'tpope/vim-characterize' -- ga
use 'tpope/vim-abolish'
use 'gennaro-tedesco/nvim-peekup'
use 'AndrewRadev/bufferize.vim'
use 'windwp/nvim-projectconfig'
projectconfig = require('nvim-projectconfig')
projectconfig.setup()

-- Display.
use 'dhruvasagar/vim-zoom' -- <C-w>m

--use 'Konfekt/vim-alias'
--use 'Shougo/echodoc.vim' " Displays function signatures from completions
--use 'thinca/vim-ft-vim_fold'

EOF

" vim:textwidth=0
