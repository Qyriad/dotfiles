local qyriad = require('qyriad')

qyriad.lsp = qyriad.lsp or { }
qyriad.lsp.tsgo = qyriad.lsp.tsgo or { }
---@param dispatchers vim.lsp.rpc.Dispatchers
---@param config vim.lsp.ClientConfig
---@return vim.lsp.rpc.PublicClient
function qyriad.lsp.tsgo.cmd(dispatchers, config)
end

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
		else
			return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
		end
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
