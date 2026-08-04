local qyriad = require('qyriad')
return qyriad.nested_tbl {
	filetypes = { 'sh', 'bash' },
	cmd = { 'bash-language-server', 'start' },
	root_markers = {
		'.git',
	},
}
