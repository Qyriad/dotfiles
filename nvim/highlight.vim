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
" In this case, solarized8_grey is actually a custom colorscheme
" in our dotfiles, *but* it calls `runtime colors/solarized8.vim`
" in order to "inherit" from it, and solarized8 won't be in the
" runtimepath until after vim-plug has done its loading, so this
" callback is still necessary.
function! SetColorscheme()
	colorscheme solarized8_grey
endfunction
call add(g:after_plugin_load_callbacks, function("SetColorscheme"))


lua << EOF
vim.g.plugins = vim.list_extend(vim.g.plugins, {
	"lifepillar/vim-solarized8",
	"chrisbra/colorizer",
	"luochen1990/rainbow",
})
EOF
