vim.lsp.config('rust-analyzer', {
	filetypes = { 'rust' },
	cmd = { 'rust-analyzer' },
	settings = {
		['rust-analyzer'] = {
			completion = {
				callable = { snippets = false },
				fullFunctionSignatures = { enable = true },
				postfix = { enable = false },
			},
			hover = {
				actions = {
					references = { enable = true },
				},
			},
			lens = { references = { method = { enable = false } } },
		},
	},
	before_init = function(init_params, config)
		if config.settings and config.settings['rust-analyzer'] then
			init_params = vim.tbl_deep_extend('force', init_params, {
				initializationOptions = config.settings['rust-analyzer'],
			})
		end
	end,
})
