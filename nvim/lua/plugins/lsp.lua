--- Plugins for LSP support.

return {
	--
	-- Generic.
	--
	--{
	--	'rcarriga/nvim-notify',
	--	opts = {
	--		--stages = 'fade',
	--		stages = 'static',
	--		fps = 60,
	--	},
	--	config = function(plugin, opts)
	--		_G._vim_notify_bak = vim.notify
	--		local notify = plugin.main or require('notify')
	--		notify.setup(opts)
	--		vim.notify = notify
	--	end,
	--	-- Setup after high priority stuff, but before lspconfig.
	--	priority = 60,
	--},
	{
		'y3owk1n/notifier.nvim',
		-- Bro why doesn't LuaLS see this type I"m dying.
		---@type notifier.config
		opts = {
			border = 'rounded',
			animation = { enabled = true },
		},
	},

	{ 'nanotee/nvim-lsp-basics', event = 'LspAttach' },

	-- Experimenting with disabling:
	--{
	--	'dgagn/diagflow.nvim',
	--	event = 'LspAttach',
	--	opts = { },
	--},
	--{
	--	"ray-x/lsp_signature.nvim",
	--	event = "LspAttach",
	--	opts = {
	--		toggle_key_flip_floatwin_setting = true,
	--		floating_window_above_cur_line = true,
	--		fix_pos = true,
	--	},
	--}


	--
	-- Language support.
	--
	{
		url = 'https://git.sr.ht/~chinmay/clangd_extensions.nvim',
		ft = { 'c', 'cpp' },
	},
	{
		'folke/lazydev.nvim',
		ft = { 'vim', 'lua' },
		dependencies = {
			'DrKJeff16/wezterm-types',
		},
		opts = {
			library = {
				{ path = "luavit-meta/library", words = { "vim%.uv" } },
				{ path = 'wezterm-types', mods = { 'wezterm' } },
			},
		},
	},
	{
		-- vim.uv typings
		"Bilal2453/luvit-meta",
		ft = { "vim", "lua" },
	}
}
