local qyriad = require('qyriad')

return qyriad.nested_tbl {
	filetypes = { 'rust' },
	cmd = { 'rust-analyzer' },
	['settings.rust-analyzer'] = {
		completion = {
			['callable.snippets'] = 'none',
			['fullFunctionSignatures.enable'] = true,
			['postfix.enable'] = false,
		},
		['hover.actions.references.enable'] = true,
		['lens.references.method.enable'] = false,
		['cargo.features'] = 'all',
	},

	before_init = function(init_params, config)
		local init_options = init_params.initializationOptions or { }
		init_params.initializationOptions = vim.tbl_deep_extend(
			'force',
			init_options,
			config.settings['rust-analyzer']
		)
		return init_params
	end,
}
