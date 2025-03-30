" Extended from lifepillar/vim-solarized8.

highlight clear
syntax reset

" Load the "base" colorscheme.
runtime colors/solarized8.vim

" Override the set name from above.
let g:colors_name = "solarized_grey"

" Override just these specific colors.
" The first one makes the normal background a medium-dark grey, instead of the blue
" solarized8 uses.
" The second one changes the Line number color to go better with said changed Normal
" background color.
highlight Normal            guibg=#1b1b1b
highlight LineNR ctermfg=11 guibg=#212728

" Make the CursorLine less saturated and less bright.
" Initial value: #073642
highlight CursorLine guibg=#13282d

" Differentiate between constants and string literals.
highlight Constant ctermfg=37 guifg=#2aa1bb
highlight String   ctermfg=37 guifg=#2aa198

" Make 'listchars' characters less conspicuous.
highlight Whitespace cterm=NONE ctermfg=239 gui=NONE guifg=#323334

" Make doc-comments be highlighted specially again.
highlight link @lsp.mod.documentation SpecialComment
highlight link @comment.documentation SpecialComment

highlight link @lsp.type.typeAlias Typedef

" Idk what's up with this one.
highlight! link @variable Identifier

highlight! link TrailingWhitespace Error

" Override search-highlights with the cursor on them to actually be distinguishable.
" Otherwise `CurSearch` is just linked to `Search`, which is not helpful.
highlight CurSearch ctermfg=0 ctermbg=11 guifg=NvimLightGrey1 guibg=NvimDarkYellow

if has("nvim-0.11")
	" Possibly temporary? They made %#CustomHighlight% in 'statusline' relative to 'hl-StatusLine'
	" instead of relative to 'hl-Normal', so not sure if there's a more sensible value here.
	highlight! link StatusLine Normal
	highlight! link StatusLineNC StatusLine
	highlight! link TabLineFill StatusLine

	" `vim.lsp.buf.hover()` now highlights the target with this.
	highlight clear LspReferenceTarget
	" guibg=oklch(0.29 0.0918 219.65)
	highlight LspReferenceTarget cterm=bold ctermbg=326 gui=bold guibg=#003244
endif

