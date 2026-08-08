_G.qyriad = _G.qyriad or require('qyriad')

_G.qyriad = qyriad.tbl_initialize(_G.qyriad, {
	plugin = {
		---@class qyriad.plugin.ui2
		ui2 = {},
	},
})

---@type vim._core
vim._core = qyriad.tbl_initialize(vim._core, {
	ui2 = require('vim._core.ui2'),
})

---@param args vim.api.keyset.create_user_command.command_args
function qyriad.plugin.ui2.cmd_ui2(args)
	local action = args.fargs[1]
	if not action then
		vim.print(vim._core.ui2.cfg)
		return
	end

	if action == 'enable' then
		vim._core.ui2.enable { enable = true }
	elseif action == 'disable' then
		vim._core.ui2.enable { enable = false }
	elseif action == 'restart' then
		vim._core.ui2.enable { enable = true }
		vim._core.ui2.enable { enable = false }
	else
		error(string.format("Invalid subcommand '%s'", action))
	end
end

---@param arg_lead string
---@param cmd_line string
---@param cursor_pos number
---@return string[]
function qyriad.plugin.ui2.cmd_ui2_completer(arg_lead, cmd_line, cursor_pos)
	-- We'll order the candidates differently based on the current state.
	local enabled = vim._core.ui2.cfg.enable or false
	local candidates
	if enabled then
		candidates = { 'restart', 'disable', 'enable' }
	else
		candidates = { 'enable', 'restart', 'disable' }
	end
	return vim.iter(candidates)
		:filter(function(cand)
			return vim.startswith(cand, arg_lead)
		end)
		:totable()
end

vim.api.nvim_create_user_command('Ui2', qyriad.plugin.ui2.cmd_ui2, {
	desc = "Controls Neovim's experimental 'ui2' feature",
	nargs = '?',
	complete = qyriad.plugin.ui2.cmd_ui2_completer,
})

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		vim._core.ui2.enable {
			enable = true,
		}
	end,
})
