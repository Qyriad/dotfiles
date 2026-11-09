--- Plugins for Git and Jujutsu.
return {
	'tpope/vim-fugitive',
	{
		'lewis6991/gitsigns.nvim',
		opts = {
			-- Don't fill the signcolumn for untracked files.
			attach_to_untracked = false,
			-- Lower priority than MarkSigns.
			sign_priority = 9,
		},
	},
	{
		'akinsho/git-conflict.nvim',
		opts = {},
	},
	{
		'NicolasGB/jj.nvim',
		opts = { },
	},
	'rafikdraoui/jj-diffconflicts',
}
