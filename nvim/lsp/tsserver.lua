local qyriad = require('qyriad')

return qyriad.nested_tbl {
	filetypes = { 'typescript', 'javascript', 'html', 'css' },
	cmd = { 'typescript-language-server', '--stdio' },
}
