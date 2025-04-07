-- Note: for lspconfig the module name is `lua_ls`.
local lua_runtime_paths = vim.iter(vim.api.nvim_get_runtime_file("lua/", true))
	:map(function(item)
		-- Remove the trailing slash.
		return item:sub(1, #item - 1)
	end)
	:totable()

vim.lsp.config('luals', {
	filetypes = { 'lua' },
	cmd = { 'lua-language-server' },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = { "?.lua", "?/init.lua" },
				pathStrict = false, -- FIXME: maybe?
			},
			workspace = {
				checkThirdParty = false,
				library = lua_runtime_paths,
			},
			diagnostics = {
				globals = { 'vim' },
			},
		},
	},
})
