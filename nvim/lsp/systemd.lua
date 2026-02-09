local qyriad = require('qyriad')

return qyriad.nested_tbl {
	filetypes = { 'systemd' },
	cmd = { 'systemd-lsp' },
}
