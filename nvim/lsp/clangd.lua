local qyriad = require('qyriad')

M = { }

vim.lsp.config('clangd', qyriad.nested_tbl {
	filetypes = {
		'c',
		'cpp',
		'objc',
		'objcpp',
		'cuda',
		'proto',
	},
	cmd = {
		'clangd',
		'--rename-file-limit=100',
	},
	capabilities = {
		['textDocument.completion.editsNearCursor'] = true,
		offsetEncoding = { 'utf-8', 'utf-16' },
	},
	--root_dir = function(bufnr)
	--	local root = vim.fs.root(vim.fs.abspath(vim.fn.bufname(bufnr)), {
	--		'.clangd',
	--		'.clang-tidy',
	--		'.clang-format',
	--		'compile_commands.json',
	--		'compile_flags.txt',
	--		'.git',
	--	})
	--	vim.notify(vim.inspect({ root = root }))
	--	return root
	--end,
	--capabilities = {
	--	textDocument = { completion = { editsNearCursor = true } },
	--	offsetEncoding = { 'utf-8', 'utf-16' },
	--},
})

