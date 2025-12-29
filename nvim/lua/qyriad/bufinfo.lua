---@class qyriad.BufInfo
---@field bufnr integer
---@field bufname string
---@field filetype string
---@field isloaded boolean
---@field line_count integer
local BufInfo = { }
BufInfo.__index = BufInfo
setmetatable(BufInfo, BufInfo)
function BufInfo.new(tbl)
	vim.validate('tbl', tbl, 'table')
	return setmetatable(tbl, BufInfo)
end

---@param bufnr integer
function BufInfo.from_bufnr(bufnr)
	return BufInfo.new {
		bufnr = bufnr,
		bufname = vim.api.nvim_buf_get_name(bufnr),
		filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr }),
		isloaded = vim.api.nvim_buf_is_loaded(bufnr),
		line_count = vim.api.nvim_buf_line_count(bufnr),
	}
end

---@return Iter
function BufInfo:iter_keymaps()
	return vim.iter(vim.api.nvim_buf_get_keymap(self.bufnr, ''))
end

---@return Iter
function BufInfo:iter_lines()
	return vim.iter(vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, true))
end

function BufInfo:list_vars()
	return vim.fn.getbufvar(self.bufnr, '')
end


---@nodoc
---@class BufInfoOp
---@operator call:qyriad.BufInfo

return setmetatable(BufInfo, {
	__call = function(_, ...)
		return BufInfo.new(...)
	end,
}) --[[@as BufInfoOp]]
