local qyriad = require('qyriad')

---@type vim.lsp.ClientConfig
return qyriad.nested_tbl {
	---@param dispatchers vim.lsp.rpc.Dispatchers
	---@param config vim.lsp.ClientConfig
	---@return vim.lsp.rpc.PublicClient
	cmd = function(dispatchers, config)
		local cmd = 'tsgo'
		local local_cmd = (config or {}).root_dir and config.root_dir .. '/node_modules/.bin/tsgo'
		if local_cmd and vim.fn.executable(local_cmd) == 1 then
			cmd = local_cmd
		end
		if dispatchers == nil then
			return { cmd, '--lsp', '--stdio' }
		end

		return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
	end,
	filetypes = {
		'javascript',
		'javascriptreact',
		'javascript.jsx',
		'typescript',
		'typescriptreact',
		'typescript.tsx',
	},
}
