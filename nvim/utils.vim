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
	p[normalized] = require(main)
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
			{ details = true, overlap = true }
		)
		-- Only add this to the return value if this value isn't empty.
		if #current_line_extmarks_for_ns > 0 then
			ret[ns_name] = current_line_extmarks_for_ns
		end
	end

	return ret
end

EOF


" Calls a function, and, if it returns a value, echoes it.
" If it doesn't return a value, then this function prints nothing,
" and thus doesn't hide anything callees may have explicitly
" echoed themselves.
function CallOrEcho(func_call_expr)
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
command! Cfile silent !echo % | tr -d '\n' | tmux load-buffer -
