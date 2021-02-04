"
" Color customization.
" LSP-related colors are in lsp.vim instead.
"

" Make the highlight color for the colorcolumn not obnoxious, but still stand out.
"highlight ColorColumn ctermbg=236 guibg=#303030
"highlight ColorColumn ctermbg=236 guibg=#121212
" Also bold the line number.
"highlight CursorLineNr cterm=bold gui=bold guifg=#af5f00
" Make the folded text color not suck.
"highlight Folded ctermbg=17 guibg=#303030

" Make the completion menu look not ungodly
highlight Pmenu guibg=#303030 guifg=#5a95f4

" Enable truecolor.
set termguicolors
" Reset some things to to term defaults.
"highlight Statement guifg=#af5f00
"highlight Comment guifg=#0aa6da
"highlight PreProc guifg=#c397d8
"highlight Identifier guifg=#70c0ba
"highlight Constant guifg=#cf0002
"highlight Type guifg=#00cc00
"highlight Special guifg=#c397d8
"highlight LineNr gui=none guifg=#af5f00

" Actually be able to see searched stuff
"highlight Search guibg=#a0a0a0
highlight Search guibg=#5c5c5c guifg=#ffffff gui=NONE

command! Hitest :source $VIMRUNTIME/syntax/hitest.vim

let g:rainbow_active = 1 " luochen1990/rainbow

colorscheme solarized8

highlight Normal                          guibg=#1c1c1c
highlight LineNr ctermfg=11               guibg=#212728

lua << EOF
--vim.g.plugins = vim_list_cat(vim.g.plugins, {
--	"lifepillar/vim-solarized8",
--	"chrisbra/colorizer",
--	"luochen1990/rainbow",
--})
EOF
