local qyriad = require('qyriad')

return qyriad.nested_tbl {
	filetypes = { 'toml' },
	cmd = { 'taplo', 'lsp', 'stdio' },
}
