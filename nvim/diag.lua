local qyriad = require('qyriad')
local sev = vim.diagnostic.severity

vim.cmd[[
nnoremap <leader>ll <Cmd>lwindow<CR>
nnoremap <leader>lo <Cmd>lopen<CR>
nnoremap <leader>lc <Cmd>lclose<CR>

augroup FixQf
	autocmd! BufReadPost quickfix nnoremap <buffer> <CR> <CR>
augroup END
]]

function qyriad._vaguely_in(needle, haystack)
	needle = needle
		:lower()
		:gsub(" ", "_")
		:gsub("-", "_")
	haystack = haystack
		:lower()
		:gsub(" ", "_")
		:gsub("-", "_")

	return haystack:match(needle) ~= nil
end

---@type vim.diagnostic.Opts
DIAG_CONFIG = {
	severity_sort = true,
	update_in_insert = false,

	float = { severity = { min = sev.HINT } },

	signs = {
		severity = { min = sev.WARN },
	},
	underline = {
		severity = { min = sev.INFO },
	},
	virtual_lines = {
		severity = sev.ERROR,
		format = function(diagnostic)
			if not diagnostic.source then
				return nil
			end
			-- Don't include the code part if it's already included
			-- in the message.
			local code_part = ""
			if diagnostic.code then
				if not qyriad._vaguely_in(diagnostic.code, diagnostic.message) then
					code_part = ("%s: "):format(diagnostic.code)
				end
			end
			local source_part = ""
			if diagnostic.source then
				source_part = (" (src: %s)"):format(diagnostic.source)
			end
			local msg = vim.split(diagnostic.message, "\n", {
				plain = true,
				trimempty = true,
			})[1]
			return ([[%s%s%s]]):format(
				code_part,
				msg,
				source_part
			)
		end,

	},
	virtual_text = {
		severity =  { min = sev.WARN },
		virt_text_pos ='eol_right_align',
		-- Hide the virtual text when scrolling.
		virt_text_hide = true,
	},
}
vim.diagnostic.config(DIAG_CONFIG)

vim.diagnostic.handlers.loclist = {
	show = function(namespace, bufnr, diagnostics, opts)
		opts.loclist.open = opts.loclist.open or false
		local winid = vim.api.nvim_get_current_win()
		vim.diagnostic.setloclist(opts.loclist)
		vim.api.nvim_set_current_win(winid)
	end
}

use {
	'cbochs/portal.nvim',
	opts = {

	},
}
