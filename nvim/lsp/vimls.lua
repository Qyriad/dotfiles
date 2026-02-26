return  {
	filetypes = { 'vim' },
	cmd = { 'vim-language-server', '--stdio' },
	root_markers = { "init.vim", "init.lua", ".git" },
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
}
