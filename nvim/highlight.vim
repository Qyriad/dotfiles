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


" We have to set the colorscheme as a after-plugin-load-callback,
" because :colorscheme requires the colorscheme to already exist!
function! SetColorscheme()
	colorscheme solarized8
	highlight Normal            guibg=#1c1c1c
	highlight LineNr ctermfg=11 guibg=#212728
endfunction
call add(g:after_plugin_load_callbacks, function("SetColorscheme"))


lua << EOF
vim.g.plugins = vim.list_extend(vim.g.plugins, {
	"lifepillar/vim-solarized8",
	"chrisbra/colorizer",
	"luochen1990/rainbow",
})
EOF
