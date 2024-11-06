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

use {
	"lifepillar/vim-solarized8",
	--config = ":colorscheme solarized8_grey",
	config = function()
		vim.cmd("colorscheme solarized8_grey")
	end,
	lazy = false,
	priority = 100,
}
use "gko/vim-coloresque"
use "luochen1990/rainbow"
-- Briefly highlight text that changes during an undo or redo.
use {
	"tzachar/highlight-undo.nvim",
	opts = { },
}
use {
	"folke/paint.nvim",
	--filetype = { "rust" },
	--opts = {
	--	highlights = {
	--		{
	--			filter = { filetype = "rust" },
	--			hl = "Statement",
	--			pattern = "&(raw)%s",
	--		}
	--	},
	--},
}
EOF

