"
" Color customization.
" LSP-related colors are in lsp.vim instead.
"

" Enable truecolor.
set termguicolors

command! Hitest :source $VIMRUNTIME/syntax/hitest.vim

let g:rainbow_active = 1 " luochen1990/rainbow

" Disable rainbow for cmake, mediawiki, and tvtropes
augroup ft_disable_rainbow
	autocmd! FileType cmake,mediawiki,tvtropes RainbowToggleOff
augroup END


lua << EOF
local use = packer.use
use { "lifepillar/vim-solarized8", config = function() vim.cmd("colorscheme solarized8_grey") end }
use "gko/vim-coloresque"
use "luochen1990/rainbow"
EOF
