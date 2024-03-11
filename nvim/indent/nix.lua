local qpat = require('qpat')
local pat = qpat.qpattern

vim.cmd([[
	setlocal expandtab
	setlocal shiftwidth=2
	setlocal indentexpr=v:lua.NixIndent()
]])

vim.opt_local.indentkeys:append {
	'0=then',
	'0=else',
	'0=inherit',
	'0=in',
	'*<Return>'
}

local PAT = {
	LINE_COMMENT = pat[[^\s*#]],
	-- Syntax groups to skip.
	SKIPPED_SYN = pat[[%(Comment|String)$]],
	LET = pat[[%(<|^)let%(>|$)]],
	IN = pat[[%(<|^)in%(>|$)]],

	-- vim.trim + multiline used for readability here, where the pattern contains
	-- [] characters year the raw string delimiters.
	-- FIXME: this doesn't work if the opening brace or square bracket is not at
	-- end of the line, or if the closing one is not at the start of the line.
	ATTR_LIST_START = pat(vim.trim([[
		%(\{|\[)\s*$
	]])),
	ATTR_LIST_END = pat(vim.trim([[
		^\s*%(\}|\])%($|;|:|\))
	]])),

	LIST_START = pat(vim.trim([[
		\[\s*$
	]])),

	LIST_END = pat(vim.trim([[
		^\s*\]
	]])),

	-- An open paren, equals sign, or inherit at the end of a line
	-- is an multiline expression.
	-- The next line will be indented one more.
	INCOMPLETE_START = pat(vim.trim([[
		%([(=]$)|%(inherit\s*%(.+[^;]$))
	]])),

	PAREN_BLOCK_END = pat[[^\s*\)]],

	SEMICOLON_BLOCK_END = pat[[^\s*;%(>|$)]],

	BINDINGS_BLOCK_START = pat(vim.trim([[
		%(\{$)|%(\s*let%(>|$))
	]])),

	LAMBDA_BODY_START = pat[[:$]],
}

for key, value in pairs(PAT) do
	vim.b['nix_pat_' .. key] = value.string
end

local function which_closest_diff(target, list_to_compare)
	local min_diff = math.huge
	local min_value = nil

	for i, value in ipairs(list_to_compare) do
		local diff = target - value
		if diff < min_diff then
			min_diff = diff
			min_value = value
		end
	end

	return min_value
end

function NixIndent(lnum)

	local lnum = lnum or vim.v.lnum

	-- The line number of the most recent non-blank line above the current.
	local prevlnum = vim.fn.prevnonblank(lnum - 1)

	-- Use zero indentation at the beginning of the file.
	if prevlnum == 0 then
		return 0
	end

	-- The contents of the most recent non-blank line above the current.
	local prevline = vim.fn.getline(prevlnum)

	-- The indent level of the previous line.
	local previndent = vim.fn.indent(prevlnum)

	-- Tracking the current indent level.
	local ret = previndent

	local shiftwidth = vim.fn.shiftwidth()

	-- The contents of the current line.
	local line = vim.fn.getline(lnum)

	-- The first non-blank column of the current line.
	local caretcolumn = line:match('^%s*'):len() + 1
	local nonblank_synid = vim.fn.synID(lnum, caretcolumn, true)
	local nonblank_synname = vim.fn.synIDattr(nonblank_synid, 'name')

	local nixattr_synid = vim.fn.hlID('nixAttribute')

	-- The syntax ID at the beginning of the current line.
	local synid = vim.fn.synID(lnum, 1, true)
	local synname = vim.fn.synIDattr(synid, 'name')

	-- Keep line comments as they are.
	-- FIXME: does this correctly handle strings?
	if PAT.LINE_COMMENT:match_str(line) then
		return vim.fn.indent(lnum)
	end

	if PAT.SKIPPED_SYN:match_str(synname) then
		-- FIXME: do string handling.
		-- For now, just leave strings as they are.
		return vim.fn.indent(lnum)
	end

	-- Main indentation logic starts here.

	local skip_expr = 'nix#syn_should_ignore()'

	if PAT.INCOMPLETE_START:match_str(prevline) then
		--defer_notify('INCOMPLETE_START')
		return ret + shiftwidth
	end

	-- If this is an attrset binding, indent it one more than the line where the binding starts.
	if nonblank_synid == nixattr_synid then
		-- HACK: forcibly ignore the current line without moving the cursor, because for some reason
		-- moving the cursor first seems to cause other problems for searchpair().
		local very_skip = string.format('nix#syn_should_ignore() || line(".") == %d', lnum)
		local attrset_start = vim.fn.searchpair('{', '', '}', 'bnWz', very_skip)
		local let_start = vim.fn.searchpair(PAT.LET.string, '', PAT.IN.string, 'bnW', very_skip)
		local inherit_start = vim.fn.searchpair(
			[[\v%(<|^)inherit%(>|$)]],
			'',
			';',
			'bnW',
			skip_expr
		)
		-- Use whichever one is closer.
		local closest = which_closest_diff(lnum, { attrset_start, let_start, inherit_start })
		return vim.fn.indent(closest) + shiftwidth
	end

	-- Indent `in` lines the same as their matching `let` lines.
	if PAT.IN:match_str(line) then
		-- Save the cursor position, since we're about to move it.
		local cursorpos = vim.fn.getcurpos()
		vim.cmd.normal('^')

		local matching_let = vim.fn.searchpair(
			PAT.LET.string, -- start
			'', -- middle
			PAT.IN.string, -- stop
			'bnW',
			skip_expr
		)

		vim.fn.setpos('.', cursorpos)
		return vim.fn.indent(matching_let)
	end

	if PAT.ATTR_LIST_END:match_str(line) then
		if not PAT.ATTR_LIST_START:match_str(prevline) then
			return ret - shiftwidth
		else
			return ret
		end
	end

	if PAT.PAREN_BLOCK_END:match_str(line) then
		return ret - shiftwidth
	end

	if PAT.SEMICOLON_BLOCK_END:match_str(line) then
		return ret - shiftwidth
	end

	if PAT.LIST_END:match_str(line) then
		return ret - shiftwidth
	end

	if PAT.LIST_START:match_str(prevline) then
		return ret + shiftwidth
	end

	if PAT.BINDINGS_BLOCK_START:match_str(prevline) then
		return ret + shiftwidth
	end

	if PAT.IN:match_str(prevline) then
		-- We need to get the syntax group of the `in`,
		-- to make sure it's not in a string or comment.
		local posret = vim.fn.matchstrpos(
			prevline,
			-- matchstrpos() uses 'matchcase', so we prepend \C to force case sensititivty.
			[[\C]] .. PAT.IN.string
		)
		local in_start_col = posret[2]
		local in_syn_id = vim.fn.synID(prevlnum, in_start_col, true)
		local in_syn_name = vim.fn.synIDattr(in_syn_id, 'name')
		if not PAT.SKIPPED_SYN:match_str(in_syn_name) then
			return ret + shiftwidth
		end
	end

	if PAT.LAMBDA_BODY_START:match_str(prevline) then
		-- If the lambda definition is at top-level, then don't indent the body.
		if previndent ~= 0 then
			return ret + shiftwidth
		end
	end

	return ret
end
