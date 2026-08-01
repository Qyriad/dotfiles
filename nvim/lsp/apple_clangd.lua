local qyriad = require('qyriad')
clangd_cmd = {
	'/usr/bin/clangd',
	'--rename-file-limit=100',
	'--clang-tidy',
	'--query-driver=**/*',
}

---@type vim.lsp.ClientConfig
return qyriad.nested_tbl {
	filetypes = { 'objc', 'objcpp' },
	cmd = clangd_cmd,
}
