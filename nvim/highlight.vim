"
" Color customization.
" LSP-related colors are in lsp.vim instead.
"

" Enable truecolor.
set termguicolors

command! Hitest :source $VIMRUNTIME/syntax/hitest.vim

use {
	"lifepillar/vim-solarized8",
	--config = ":colorscheme solarized8_grey",
	config = function()
		--vim.cmd("colorscheme solarized8_grey")
		vim.cmd("colorscheme catppuccin-macchiato")
	end,
	lazy = false,
	priority = 100,
}
use "hiphish/rainbow-delimiters.nvim"
-- Briefly highlight text that changes during an undo or redo.
use {
	"tzachar/highlight-undo.nvim",
	opts = { },
}

