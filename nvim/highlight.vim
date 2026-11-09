"
" Color customization.
" LSP-related colors are in lsp.vim instead.
"

" Enable truecolor.
set termguicolors

command! Hitest :source $VIMRUNTIME/syntax/hitest.vim

" idk why setup() in lazy's config() isn't working.
augroup PaintHighlightRust
	autocmd! FileType rust call v:lua.p.paint.setup(g:paint_highlights)
augroup END

lua << EOF
local raw_const = {
	filter = { filetype = "rust" },
	hl = "Statement",
	-- Rust's treesitter parser doesn't know about the &raw syntax yet.
	pattern = "&(raw%sconst)%s",
}
local raw_mut = {
	filter = { filetype = "rust" },
	hl = "Statement",
	-- Rust's treesitter parser doesn't know about the &raw syntax yet.
	pattern = "&(raw%smut)%s",
}
vim.g.paint_highlights = {
	highlights = {
		raw_const,
		raw_mut,
	},
}
EOF
