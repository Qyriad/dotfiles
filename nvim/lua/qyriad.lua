local M = {}

M.BufInfo = require('qyriad.bufinfo')

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

M.t = {
	number = type(0),
	string = type(""),
	boolean = type(true),
	table = type({}),
	["function"] = type(function() end),
	thread = "thread",
	userdata = "userdata",
	["nil"] = "nil",
}

---Run a callback based on the type of the value.
---@param value any
---@param handlers table<string|string[], function>
function M.switch(value, handlers)
	local value_type = type(value)
	local simple_handler = handlers[value_type]
	if simple_handler ~= nil then
		return simple_handler(value)
	end

	if handlers._ ~= nil then
		return handlers._(value)
	end

	error(string.format("no handler specified for type %s", value_type))
end

---Lua-ish version of `empty()`, ish.
---@param value any
---@return boolean
function M.vim_isempty(value)
	if value == nil then
		return true
	end

	if value == false then
		return true
	end


	local value_type = type(value)
	if value_type == M.t.number then
		return value == 0
	elseif value_type == M.t.string then
		return value == ""
	elseif value_type == M.t.table then
		-- Also covers vim.empty_dict()
		return next(value) == nil
	end

	return false
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

function _save_mark_cmd_impl(filename)
	local file, err = io.open(filename, "w")
	if not file then
		error(string.format("Error opening '%s' to save marks: '%s'", filename, err))
	end

	local marks = vim.iter(vim.fn.getmarklist())
	local data = vim.json.encode(marks)
	file:write(data)
	file:flush()
	file:close()
end

---Opens help for `subject` in the current window.
---@param subject string
function M.help_curwin(subject)
	vim.validate('subject', subject, 'string')

	local curtab = vim.api.nvim_get_current_tabpage()
	vim.cmd.help {
		args = { subject },
		mods = {
			-- Yes this has to be `1`, not `true`.
			tab = 1,
		}
	}

	local helpwin = vim.api.nvim_get_current_win()
	local helpbuf = vim.api.nvim_get_current_buf()

	-- `vim.api.nvim_{get,set}_{cursor,config}` are not enough,
	-- as they do not restore the view positioning.
	local helpsave = vim.fn.winsaveview()

	-- Restore the previous tabpage (and thus, the previous window).
	vim.api.nvim_set_current_tabpage(curtab)

	-- Attach that window to the help buffer, and restore its viewport.
	vim.api.nvim_set_current_buf(helpbuf)
	vim.fn.winrestview(helpsave)

	-- And close that temporary tabpage.
	vim.api.nvim_win_close(helpwin, false)
end

vim.api.nvim_create_user_command("HelpCurwin", function(opts) M.help_curwin(opts.args) end, {
	nargs = 1,
	complete = "help",
})

---@class VimKeymap : vim.keymap.set.Opts
---
---@field lhs string The {lhs} of the mapping as it would be typed.
---@field lhsraw string The {lhs} mapping as raw bytes.

--- Returns all mappings in `mode` that match `lhs`, like `:help :map` shows.
---@param mode string
---@param lhs string
---@return table
---
--- Works like `:map <lhs>`, and returns things that *start* with `<lhs>` as well.
function M.vim_keymap_get(mode, lhs)
	local matching_mode = vim.api.nvim_get_keymap(mode)

	local matching_lhs = vim.iter(matching_mode)
		---@param mapargs VimKeymap
		:filter(function(mapargs)
			return vim.startswith(vim.keycode(mapargs.lhs), vim.keycode(lhs))
		end)
		:totable()

	return matching_lhs
end

---@param iter Iter
function M.opaque_iter(iter)
	return setmetatable(iter, {
		__tostring = function(self)
			return string.format("vim.Iter over %s elements", #self._table)
		end,
	})
end

function WinInfo(tbl)
	return setmetatable(tbl, {
		__index = {
			is_floating = function(self)
				return self.config.relative ~= ""
			end,
		},
	})
end

function M.iter_wins()
	--vim.iter(vim.api.nvim_list_wins()):map(function(win) return qyriad.tbl_override({ win = win}, vim.api.nvim_win_get_config(win)) end):map(function(win) return qyriad.tbl_override(win, { bufnr = vim.api.nvim_win_get_buf(win.win) }) end):map(function(win)
	return vim.iter(vim.api.nvim_list_wins()):map(function(winid)
		local config = vim.api.nvim_win_get_config(winid)
		local bufnr = vim.api.nvim_win_get_buf(winid)
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		local bufinfo = {
			bufnr = bufnr,
			bufname = bufname,
			filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr }),
			isloaded = vim.api.nvim_buf_is_loaded(bufnr),
			line_count = vim.api.nvim_buf_line_count(bufnr),
			--keymaps = M.opaque_iter(vim.iter(vim.api.nvim_buf_get_keymap(bufnr, ''))),
			keymaps = function(self) return vim.iter(vim.api.nvim_buf_get_keymap(self.bufnr, '')) end,
			iter_lines = function(self)
				return vim.iter(vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, true))
			end,
			--iter_vars = function(self)
			--	return vim.iter(vim.fn.getbufvar(self.bufnr, ''))
			--end,
			list_vars = function(self)
				return vim.fn.getbufvar(self.bufnr, '')
			end
		}

		local wininfo = {
			win = winid,
			bufnr = bufnr,
			bufinfo = bufinfo,
			config = config,
			floating = config.relative ~= "",
		}
		return WinInfo(wininfo)
	end)
end


function M.lsp_iter_clients()
	return vim.iter(vim.lsp.get_clients())
		:map(function(c) return {
			id = c.id,
			name = c.name,
			buffers = vim.tbl_keys(c.attached_buffers)
		} end)
		:totable()
end


---@param mode string
---@param lhs string
---@param desc string
function M.add_desc_to_keymap(mode, lhs, desc)
	local global_keymaps = vim.api.nvim_get_keymap(mode)

	-- Find the keymap with that LHS.
	local matching_keymaps = vim.iter(global_keymaps)
		:filter(function(mapargs) return mapargs.lhsraw == vim.keycode(lhs) end)
		:totable()

	if #matching_keymaps ~= 1 then
		error("did not find exactly 1 match")
	end

	local matching_keymap = matching_keymaps[1]

	-- Unmap that keymap.
	vim.api.nvim_del_keymap(mode, matching_keymap.lhs)

	-- Make a new, identical one, but with the description.
	matching_keymap.opts.desc = desc
	vim.api.nvim_set_keymap(matching_keymap.mode, matching_keymap.lhs, matching_keymap.rhs, matching_keymap.opts)
end

return M
