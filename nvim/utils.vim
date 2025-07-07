"
" "Utility" functions and commands for our own convenience.
"
" Every codebase ends up with a "util" or "utils" module, and finally
" even our Neovim configuration has yielded.
" These functions are not "core" to our Vim experience, but are useful.
"

lua <<EOF
-- If given a table, separates its numeric key/value pairs from other pairs,
-- effectively separating a mixed table into an array and a map.
-- Returns two values:
--   - The separated-out array-like table.
--   - The separated-out map-like table.
-- If given anything other than a table, simply returns the value as is.
function separate(value)

	if type(value) ~= 'table' then
		return value
	end

	local array = { }
	local map = { }

	for k, v in pairs(value) do
		if type(k) == 'number' then
			array[k] = v
		else
			map[k] = v
		end
	end

	return array, map
end

function get_visual()
	local bufnum, start_line, start_col, _start_offset = unpack(vim.fn.getpos("'<"))
	local _, end_line, end_col, _end_offset = unpack(vim.fn.getpos("'>"))
	local lines = vim.api.nvim_buf_get_text(
		bufnum,
		start_line - 1,
		start_col - 1,
		end_line - 1,
		end_col,
		{}
	)

	return vim.fn.join(lines, "\n")
end

-- vim.notify() that is safe to call in restricted functions
function defer_notify(msg)
	vim.defer_fn(function() vim.notify(msg) end, 0)
end

EOF

" Vimscript wrapper to the above
function! Notify(msg) abort
	call v:lua.defer_notify(a:msg)
endfunction

" Inserts the current visual selection text into the command-line.
cnoremap <expr> <C-t> v:lua.get_visual()
" Inserts the `:help word` under the cursor into the command-line.
cnoremap <expr> <C-g> expand("<cword>")

lua <<EOF

-- Calls telescope.builtin.diagnostics with our preferred options.
function telescope_diagnostics()
	return telescope.builtin.diagnostics {
		bufnr = 0,
	}
end

local VERY_MAGIC = [[\v]]
local PREFIX_PATTERN = VERY_MAGIC .. vim.fn.trim([[ ^(n?)vim[_] ]])
local SUFFIX_PATTERN = VERY_MAGIC .. vim.fn.trim([[ [_.](n?)vim$ ]])

-- Creates a key in the global table `p`, whose name is the normalized
-- main lua module of a plugin, and whose value is that module `require()`'d.
-- This function gets called from some autocommands set in init.vim.
function lazy_import_plugin(plugin_name, plugin)

	-- The LazyLoad event only passes us the plugin name, so in that case we'll have to find
	-- the plugin table object that matches that name from Lazy's API.
	-- The LazyDone event callback passes us the full plugin table, so if that's passed
	-- then we don't need to worry.
	if plugin == nil then
		plugin = lazy.core.config.plugins[plugin_name]
	end

	if plugin == nil then
		vim.notify("Cannot import: no plugin called " .. plugin_name, vim.log.levels.WARN)
		return
	end

	local main = lazy.core.loader.get_main(plugin)
	if type(main) ~= "string" or main == "" then
		return
	end

	local normalized = lazy.core.util.normname(main)

	vim.notify(normalized .. ' = require("' .. main .. '")', vim.log.levels.DEBUG)
	p[normalized] = vim.tbl_extend('force', p[normalized] or { }, require(main))
end

-- Returns a table, each key of which is a namespace name that corresponds to all extmarks
-- in that namespace on the current line. extmark values are of the form { extmark_id, row, col }.
-- Details about an extmark can be retrieved with nvim_buf_get_extmark_by_id()
function get_extmarks_on_current_line(opts)

	local ret = { }

	-- Line numbers are 1 indexed but row indexes are 0 indexed in the Neovim API, so - 1 it is.
	local current_row_index = vim.api.nvim_win_get_cursor(0)[1] - 1
	local range = {
		current_row = {
			-- For columns, 0 indicates the start of the column, and -1 indicates the end of the column.
			col_from_start = { current_row_index, 0 },
			col_to_end = { current_row_index, -1},
		},
	}

	for ns_name, ns_id in pairs(vim.api.nvim_get_namespaces()) do
		local current_line_extmarks_for_ns = vim.api.nvim_buf_get_extmarks(
			0, -- 0 to indicate current buffer
			ns_id,
			range.current_row.col_from_start,
			range.current_row.col_to_end,
			{ details = true }
		)
		-- Only add this to the return value if this value isn't empty.
		if #current_line_extmarks_for_ns > 0 then
			ret[ns_name] = current_line_extmarks_for_ns
		end
	end

	return ret
end

function save_tabpage_layout()
	local wins = { }
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local winconfig = vim.api.nvim_win_get_config(winid)
		if winconfig.relative == '' then
			wins[tostring(winid)] = winconfig
		end
	end

	vim.t.saved_layout = wins

	return wins
end

function restore_tabpage_layout()
	local wins = vim.t.saved_layout
	for winid, winconfig in pairs(wins) do
		vim.api.nvim_win_set_config(tonumber(winid), winconfig)
	end
	vim.cmd.doautocmd("WinResized")
end

function try_restore_tabpage_layout()
	local wins = vim.t.saved_layout
	if wins == nil then
		return
	end
	for winid, winconfig in pairs(wins) do
		vim.api.nvim_win_set_config(tonumber(winid), winconfig)
	end
	vim.cmd.doautocmd("WinResized")
end

EOF

command! SaveTabpageLayout call v:lua.save_tabpage_layout()
command! RestoreTabpageLayout call v:lua.restore_tabpage_layout()
command! TryRestoreTabpageLayout call v:lua.try_restore_tabpage_layout()
nnoremap <leader>st <Cmd>SaveTabpageLayout<CR>
nnoremap <leader>rt <Cmd>RestoreTabpageLayout<CR>

"augroup WinchTabLayout
"	autocmd! Signal SIGWINCH autocmd ++once WinResized * TryRestoreTabpageLayout
"augroup END

lua <<EOF

---@param path string A path in 'runtimepath' to search for.
---@return string A path in 'runtimepath' if found.
function rtp(path)
	return vim.fn.globpath(vim.o.runtimepath, path)
end

---@param arglead string
---@param _cmdline string
---@param _cursorpos integer
---@return string A newline separated list of completion results.
function rtp_complete(arglead, _cmdline, _cursorpos)


	local ret = { }

	for _, rtp in ipairs(vim.opt.runtimepath:get()) do
		-- Append the directory / if we need to.
		if string.sub(rtp, -1) ~= "/" then
			rtp = rtp .. "/"
		end

		local glob_results = vim.fn.glob(rtp .. arglead .. "*", false, true)

		for _, glob_result in ipairs(glob_results) do

			-- For tab completion, include only directories, .vim files, and .lua files.
			local is_dir = vim.fn.isdirectory(glob_result) == 1
			local is_vim = string.match(glob_result, "%.vim$") ~= nil
			local is_lua = string.match(glob_result, "%.lua$") ~= nil
			--local is_sourceable = vim.fn.glob(glob_result
			if is_dir or is_vim or is_lua then
				-- Remove the rtp-part from the result.
				local complete_value = string.sub(glob_result, #rtp + 1)

				-- And if the result is a directory, append a slash.
				if is_dir then
					complete_value = complete_value .. "/"
				end

				-- Finally add the finished string to our completion results.
				if not vim.tbl_contains(ret, complete_value) then
					table.insert(ret, complete_value)
				end
			end
		end
	end

	--ret = vim.fn.getcompletion("runtime " .. arglead, "cmdline")
	return ret
end

EOF

""" Returns the specified path in 'runtimepath' if found.
function! Rtp(path) abort
	return v:lua.rtp(a:path)
endfunction

function! RtpCommand(path, bang) abort
	let l:result = v:lua.rtp(a:path)
	if !empty(a:bang)
		let @" = l:result
		echomsg "yanked " . l:result
	else
		echomsg l:result
	endif
endfunction

""" Echos the specified path in 'runtimepath' if found. Yanks if bang is given.
command! -nargs=1 -bang -complete=customlist,v:lua.rtp_complete Rtp call RtpCommand(<q-args>, <q-bang>)

"command! -nargs=2 -complete=customlist,v:lua.rtp_complete Runtime


" Calls a function, and, if it returns a value, echoes it.
" If it doesn't return a value, then this function prints nothing,
" and thus doesn't hide anything callees may have explicitly
" echoed themselves.
function! CallOrEcho(func_call_expr)
	let l:ret = execute("echomsg " . a:func_call_expr)
	if !empty(l:ret)
		" Skip the first character, as it's a newline for some reason,
		" and we don't want an `@` in our echoed output.
		echo l:ret[1:]
	endif
endfunction

" A :command for the above function.
command! -nargs=1 -complete=function Call call CallOrEcho(<args>)


" Copy the filepath of the current buffer to Tmux.
command! Cfile silent !echo % | tr -d '\n' | tmux load-buffer -w -
