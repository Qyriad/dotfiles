local qyriad = require('qyriad')
local sev = vim.diagnostic.severity

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
	},
	virtual_text = {
		severity =  { min = sev.WARN },
		virt_text_pos ='eol_right_align',
		-- Hide the virtual text when scrolling.
		virt_text_hide = true,
	},
}
vim.diagnostic.config(DIAG_CONFIG)
