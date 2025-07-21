local qyriad = require('qyriad')

return qyriad.nested_tbl {
	filetypes = { 'make', 'autoconf', 'automake' },
	cmd = { 'autotools-language-server' },
}
