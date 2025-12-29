local BufInfo = require('qyriad.bufinfo')

---@class qyriad.WinInfo
---@field win integer
---@field bufinfo qyriad.BufInfo
local WinInfo = { }

function WinInfo.new(tbl)
	vim.validate('tbl', tbl, 'table')
	return setmetatable(tbl, WinInfo)
end

---@param winid integer `:help window-ID`
function WinInfo.from_id(winid)
	local api = vim.api
	local config = api.nvim_win_get_config(winid)
	local bufnr = api.nvim_win_get_buf(winid)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local bufinfo = {

	}
end


return setmetatable(WinInfo, {
	__call = function(_, ...)
		return WinInfo.new(...)
	end,
})
