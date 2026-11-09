return {
	{ 'nvim-lua/plenary.nvim', lazy = true },
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			telescope = require('telescope')
			telescope.setup {
				--defaults = {
				--
				--}
				--create_layout = function(picker)
				--end,
			}
			telescope.builtin = require('telescope.builtin')
			telescope.actions = require('telescope.actions')
			telescope.sorters = require('telescope.sorters')
			telescope.utils = require('telescope.utils')
			telescope.load_extension("ui-select")
		end,
	},
	{
		-- Use telescope as the picker for things like vim.lsp.buf.code_action()
		"nvim-telescope/telescope-ui-select.nvim",
	},
	{
		-- Use telescope as the picker for things like vim.lsp.buf.code_action()
		"nvim-telescope/telescope-ui-select.nvim",
	},
}
