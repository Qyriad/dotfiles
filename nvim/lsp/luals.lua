-- Note: for lspconfig the module name is `lua_ls`.

local qyriad = require('qyriad')

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
		if config.root_dir == vim.fn.stdpath('config') then
			local lines = vim.iter(lua_runtime_paths)
				:map(qyriad.summarize_path)
				:map(function(path) return string.format('- %s', path) end)
				:join('\n')
			vim.notify(lines, vim.log.levels.INFO, {
				title = '[luals] workspace.library'
			})
			config.settings = qyriad.tbl_override(config.settings, {
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
