local qyriad = require('qyriad')
return qyriad.nested_tbl {
	cmd = { 'crates-lsp' },
	filetypes = { 'toml' },
	root_markers = { 'Cargo.toml', '.git', '.jj' },
}
