local qyriad = require('qyriad')

return qyriad.nested_tbl {
	filetypes = { 'meson' },
	cmd = { 'mesonlsp', '--lsp' },
}
