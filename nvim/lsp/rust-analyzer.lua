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
})
