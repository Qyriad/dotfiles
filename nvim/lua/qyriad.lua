local M = {}

--- Like `vim.tbl_get`, but the opposite.
---
---`M.tbl_set({}, { 'first', 'second' }, 10) == { first = { second = 10 } }`
---
---@param tbl table
---@param key_list string[]
---@param value any
---@return table
function M.tbl_set(tbl, key_list, value)
	local next_tbl = tbl
	local final_key
	local final_tbl
	for _, key in ipairs(key_list) do
		if next_tbl[key] == nil then
			next_tbl[key] = { }
		end
		final_key = key
		final_tbl = next_tbl
		next_tbl = next_tbl[key]
	end

	final_tbl[final_key] = value

	return tbl
end

function M.nested_tbl(tbl)
	local ret = { }
	for key, value in pairs(tbl) do
		if type(key) == 'string' then
			local split_key = vim.split(key, '.', {
				plain = true,
				trimempty = true,
			})
			if type(value) == 'table' then
				M.tbl_set(ret, split_key, M.nested_tbl(value))
			else
				M.tbl_set(ret, split_key, value)
			end
		else
			if type(value) == 'table' then
				ret[key] = M.nested_tbl(value)
			else
				ret[key] = value
			end
		end
	end

	return ret
end

M.MODE_MAP = {
	n = 'NORMAL',
	i = 'INSERT',
	r = 'REPLACE',
	v = 'VISUAL',
	V = 'V-LINE',
	[vim.keycode('<C-v>')] = 'V-BLOCK',
	c = 'COMMAND',
	s = 'SELECT',
	S = 'S-LINE',
	[vim.keycode('<C-s>')] = 'S-BLOCK',
	t = 'TERMINAL',
}

function M.mode()
	local mode = vim.api.nvim_get_mode().mode
	return M.MODE_MAP[mode]
end

---Shortcut for `vim.tbl_extend('force', lhs, rhs)` where `lhs` can be `nil`.
---@param lhs table|nil
---@param rhs table
function M.tbl_override(lhs, rhs)
	vim.validate {
		rhs = { rhs, 'table' },
	}
	return vim.tbl_extend('force', lhs or { }, rhs)
end

function M.lsp_iter_clients()
	return vim.iter(vim.lsp.get_clients())
		:map(function(c) return {id = c.id, name = c.name } end)
		:totable()
end

return M
