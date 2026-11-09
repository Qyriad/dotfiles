--- Plugins for filetypes and syntax.

local qyriad = require('qyriad')

return {
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		opts = {},
		-- FIXME: add:
		-- https://github.com/irevoire/tree-sitter-numbat
		-- https://github.com/FoamScience/tree-sitter-xonsh
	},

	{
		'JoosepAlviste/nvim-ts-context-commentstring',
		event = 'FileType',
	},

	{
		-- Split-join, but treesitter.
		-- `gS` and `gJ`
		'Wansmer/treesj',
		config = function(plugin)
			local treesj = plugin.main or require('treesj')
			local lang_utils = require('treesj.langs.utils')

			treesj.setup(qyriad.nested_tbl {
				use_default_keymaps = false,
				['langs.nix.formals'] = lang_utils.set_preset_for_args({
					split = {
						inner_indent = 'inner',
						last_separator = true,
					},
					join = { space_in_brackets = true },
				}),
				['langs.kdl.node_children'] = lang_utils.set_preset_for_dict {
					split = {
						separator = "",
					},
					join = {
						separator = "",
						space_in_brackets = true,
						-- The semicolons in the treesitter CST for KDL aren't a separate node.
						-- Per "treesj" docs:
						-- > `separator` is a separate node, `force_insert` is a last symbol of code instruction.
						-- It seems to work.
						force_insert = ";",
					},
				},
			})
		end,
		keys = {
			{ 'gS', '<Cmd>TSJSplit<CR>', desc = "Split block" },
			{ 'gJ', '<Cmd>TSJJoin<CR>', desc = 'Join block' },
		},
		event = 'FileType',
	},

	{
		'windwp/nvim-ts-autotag',
		ft = {
			"html",
			"javascript",
			"jsx",
			"markdown",
			"php",
			"svelte",
			"tsx",
			"typescript",
			"xml",
		},
	},

	{
		'nvim-treesitter/nvim-treesitter-context',
		opts = {
			max_lines = 3,
			on_attach = function(bufnr)
				if vim.bo[bufnr].filetype == "markdown" then
					return false
				end
			end,
		},
		event = 'FileType',
	},

	{
		'nvim-treesitter/nvim-treesitter-textobjects',
		branch = 'main',
		after = 'nvim-treesitter',
		event = 'FileType',
	},

	--
	-- Language support.
	--
	{
		'phelipetls/jsonpath.nvim',
		ft = {"json"},
		config = function()
			jsonpath = require("jsonpath")
			-- FIXME: we're planning on switching statusline plugins;
			-- we'll setup how we do winbar stuff properly then.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "json",
				once = true,
				callback = function(details)
					vim.opt_local.winbar = "%#jsonKeyword#%{%v:lua.jsonpath.get()%}"
				end,
			})
		end,
	},
	{ 'Shirk/vim-gas', ft = "gas" },
	{ 'neoclide/jsonc.vim', ft = "jsonc" },
	{ 'Firef0x/PKGBUILD.vim', ft = "PKGBUILD" },
	{ 'chikamichi/mediawiki.vim', ft = "mediawiki" },
	{ 'linkinpark342/xonsh-vim', ft = "xonsh" },
	{ 'peterhoeg/vim-qml', ft = "qml" },
	{ 'dzeban/vim-log-syntax', ft = "log" },
	{ 'nickel-lang/vim-nickel', ft = "nickel" },
	{ 'qnighy/lalrpop.vim' },
	{ 'acarapetis/nvim-treesitter-jjconfig', ft = 'toml' },
	{ 'cfdrake/vim-pbxproj', ft = 'pbxproj' },
}
