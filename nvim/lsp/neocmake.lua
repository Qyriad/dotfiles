local qyriad = require('qyriad')

return qyriad.nested_tbl {
	filetypes = { 'cmake' },
	cmd = { 'neocmakelsp', 'stdio', },
}
