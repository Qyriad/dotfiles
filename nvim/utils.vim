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
