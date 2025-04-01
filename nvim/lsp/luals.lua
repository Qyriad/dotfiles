-- Note: for lspconfig the module name is `lua_ls`.
vim.lsp.config('luals', {
	filetypes = { 'lua' },
	cmd = { 'lua-language-server' }
})
