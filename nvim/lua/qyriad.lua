local M = {}

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

return M
