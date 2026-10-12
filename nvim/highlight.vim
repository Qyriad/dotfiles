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
use "gko/vim-coloresque"
-- Rainbow delimiters, via treesitter (luochen1990/rainbow is regex-syntax based, and
-- doesn't get along with treesitter highlighting).
-- Colored with the (seven stripe) lesbian flag, from the outermost nesting level in.
local lesbian_flag = {
	"#D52D00", -- dark orange
	"#EF7627", -- orange
	"#FF9A56", -- light orange
	"#FFFFFF", -- white
	"#D162A4", -- light pink
	"#B55690", -- pink
	"#A30262", -- dark pink
}
local lesbian_groups = {}
for i, _ in ipairs(lesbian_flag) do
	table.insert(lesbian_groups, "RainbowDelimiterLesbian" .. i)
end
-- Colorschemes `:highlight clear`, and some (catppuccin) define their own rainbow groups,
-- so (re)apply ours on every :colorscheme.
local function set_lesbian_delimiter_colors()
	for i, color in ipairs(lesbian_flag) do
		vim.api.nvim_set_hl(0, lesbian_groups[i], { fg = color })
	end
end
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("LesbianRainbowDelimiters", { clear = true }),
	callback = set_lesbian_delimiter_colors,
})
set_lesbian_delimiter_colors()
use {
	"HiPhish/rainbow-delimiters.nvim",
	-- This is what actually calls `vim.g.rainbow_delimiters = opts`.
	main = "rainbow-delimiters.setup",
	opts = {
		highlight = lesbian_groups,
	},
}
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

