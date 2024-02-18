local M = { }

--- Makes the pattern 'verymagic' and converts it to a vim.regex.
function M.qpattern(pattern_string)
	local obj = {
		regex = vim.regex([[\v]] .. pattern_string),
		string = [[\v]] .. pattern_string,
	}
	function obj:match_str(str)
		return self.regex:match_str(str)
	end
	function obj:match_line(str)
		return self.regex:match_line(str)
	end

	return obj
end

return M
