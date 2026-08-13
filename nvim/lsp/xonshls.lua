local qyriad = require('qyriad')

return qyriad.nested_tbl {
	filetypes = { 'xonsh' },
	cmd = { 'xonsh-lsp', '--stdio', '--python-backend=basedpyright' },
	root_markers = { 'rc.xsh', '.git', 'pyproject.toml' },
	init_options = {
		inlayHints = {
			envVarValues = true,
		},
	},
	settings = {

	},
}
