local qyriad = require('qyriad')

--- The seven-stripe lesbian flag, outermost first.
vim.g.colors_lesbian_flag = {
	"#D52D00", -- dark orange
	"#EF7627", -- orange
	"#FF9A56", -- light orange
	"#FFFFFF", -- white
	"#D162A4", -- light pink
	"#B55690", -- pink
	"#A30262", -- dark pink
}


vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('LesbianRainbowDelimiters', { clear = true }),
	callback = function()
		--vim.g.rainbow_delimiters = qyriad.tbl_override(vim.g.rainbow_delimiters, {
		--	highlight = { },
		--})
		for i, color in ipairs(vim.g.colors_lesbian_flag) do
			local group = string.format('RainbowDelimiterLesbian%d', i)
			vim.api.nvim_set_hl(0, group, { fg = color })
		end

		vim.cmd[[
			highlight! link RainbowDelimiterRed RainbowDelimiterLesbian0
			highlight! link RainbowDelimiterYellow RainbowDelimiterLesbian1
			highlight! link RainbowDelimiterBlue RainbowDelimiterLesbian2
			highlight! link RainbowDelimiterOrange RainbowDelimiterLesbian3
			highlight! link RainbowDelimiterGreen RainbowDelimiterLesbian4
			highlight! link RainbowDelimiterViolet RainbowDelimiterLesbian5
			highlight! link RainbowDelimiterCyan RainbowDelimiterLesbian6
		]]
	end,
})
--
--
return {
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = 'ColorScheme',
	},
	{
		-- Briefly highlight text that changes during an undo or redo.
		"tzachar/highlight-undo.nvim",
		opts = { },
	},
	{
		'folke/paint.nvim',
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
	},
	'gko/vim-coloresque',
}
