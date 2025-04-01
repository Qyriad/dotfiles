vim.lsp.config('vimls',  {
	filetypes = { 'vim' },
	cmd = { 'vim-language-server', '--stdio' },
	init_options = {
		isNeovim = true,
		single_file_support = true,
		runtimepath = "",
		vimruntime = "",
		suggest = {
			fromRuntimepath = true,
			fromVimruntime = "",
		},
	},
})
