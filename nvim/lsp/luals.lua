-- Note: for lspconfig the module name is `lua_ls`.
local lua_runtime_paths = vim.iter(vim.api.nvim_get_runtime_file("lua/", true))
	:map(function(item)
		-- Remove the trailing slash.
		return item:sub(1, #item - 1)
	end)
	:totable()

local library_paths = { }

return {
	filetypes = { 'lua' },
	cmd = { 'lua-language-server' },
	root_markers = {
		'init.vim',
		'init.lua',
		'wezterm.lua',
		'.git',
	},
	---@param params lsp.InitializedParams
	---@param config vim.lsp.ClientConfig
	before_init = function(params, config)
		--vim.notify(vim.inspect {
		--	root_dir = config.root_dir,
		--}, vim.log.levels.WARN)
		if config.root_dir == vim.fn.stdpath('config') then
			vim.notify(vim.inspect { library = lua_runtime_paths })
			config.settings = vim.tbl_deep_extend('force', config.settings, {
				workspace = {
					library = lua_runtime_paths,
				}
			})
		end
	end,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = { "?.lua", "?/init.lua" },
				pathStrict = false, -- FIXME: maybe?
			},
			codeLens = { enable = true },
			hint = {
				enable = true,
			},
			type = {
				inferParamType = true,
			},
			-- You're welcome.
			telemetry = { enable = true },
			--workspace = {
			--	checkThirdParty = false,
			--	library = lua_runtime_paths,
			--},
			--diagnostics = {
			--	globals = { 'vim' },
			--},
		},
	},
}
