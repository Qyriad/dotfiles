local qyriad = require('qyriad')

return {
	{
		'catppuccin/nvim',
		name = "catppuccin",
		lazy = true,
		opts = {
			auto_integrations = true,
			integrations = {
				-- We define our own, because lesbian flag.
				rainbow_delimiters = false,
			},
		},
	},

	-- The most important plugin of all time.
	'tpope/vim-surround',

	'tpope/vim-eunuch',
	{
		 -- :Tyank and :Tput
		'tpope/vim-tbone',
		cmd = { 'Tyank', 'Tput' },
	},
	-- ga
	'tpope/vim-characterize',
	'tpope/vim-abolish',
	'tpope/vim-obsession',
	'tpope/vim-repeat',
	'tpope/vim-scriptease',

	'wsdjeg/vim-fetch',

	-- Block selection range commands.
	'vim-scripts/vis',
	-- :Bdelete without messing up window layout.
	'famiu/bufdelete.nvim',
	'justinmk/vim-sneak',
	-- <C-w>m
	'dhruvasagar/vim-zoom',

	{
		'numToStr/Comment.nvim',
		opts = {
			-- Don't add a space for commented-out lines.
			padding = false,
			toggler = {
				line = "<leader>cc",
				block = "<leader>bc",
			},
			opleader = {
				line = "<leader>cc",
				block = "<leader>bc",
			},
		},
		keys = {
			{ "<leader>cc" },
			{ "<leader>bc" },
			{ "<leader>cc", mode = "v" },
			{ "<leader>bc", mode = "v" },
		},
		pre_hook = function(c)
			vim.notify(vim.inspect({
				commentstring = vim.o.commentstring,
			}))
			return vim.o.commentstring
		end,
	},

	{
		-- Auto-manage foldexpr for me.
		-- TODO: establish if we still want chrisgrieser/nvim-origami.
		'chrisgrieser/nvim-origami',
		event = "VeryLazy",
		opts = {
			autoFold = { enabled = false },
		},
	},
	-- I think we don't need this anymore.
	--{
	--	'OXY2DEV/foldtext.nvim',
	--	lazy = false,
	--},


	{
		-- We don't really like the icons but we're getting tired of plugin stuff just showing question marks
		-- and we don't want to worry about overriding it all right now.
		'nvim-tree/nvim-web-devicons',
		opts = {},
	},

	-- `:Bclose` to :close without removing the window.
	'rbgrouleff/bclose.vim',

	-- `:Bufferize <cmd>` to show output in a buffer.
	'AndrewRadev/bufferize.vim',

	{
		'chentoast/marks.nvim',
		opts = {
			-- Sure, let's try it.
			default_mappings = true,
			builtin_marks = {
				"'", -- position of the latest jump
				"^", -- position of last InsertExit
				".", -- position last change was made
			},
		},
	},

	{
		'm4xshen/autoclose.nvim',
		opts = {
			options = {
				disable_command_mode = true,
				disable_when_touch = true,
			},
			keys = {
				-- Don't autoclose quotes — single or double — or backticks.
				['"'] = { close = false },
				["'"] = { close = false },
				["`"] = { close = false },
				-- Don't autoclose square brackets either.
				["["] = { close = false },
				--["<CR>"] = { close = false },
			},
		},
		config = function(plugin, opts)
			-- HACK: autoclose overrides all our other <CR> mappings (eunuch, pum-accept).
			-- But stupid private functions mean we can't just `require('autoclose.nvim').autoclose_cr()
			-- or anything.
			-- So here we run autoclose's normal setup, and then restore the original mapping, but save
			-- the autoclose mapping in our plugin shortcut global `p.autoclose`.
			local main = require('autoclose')

			-- Get the <CR> mapping before calling setup().
			local existing_cr = vim.fn.maparg('<CR>', 'i', false, true)
			p.autoclose = qyriad.tbl_override(p.autoclose, { previous_cr = existing_cr })

			-- Let autoclose mess with things.
			main.setup(opts)


			-- Save the mapping information from autoclose.
			p.autoclose.new_cr = vim.fn.maparg('<CR>', 'i', false, true)

			-- And then restore the original mapping.
			if not vim.tbl_isempty(existing_cr) then
				vim.fn.mapset(existing_cr)
			end
		end,
	},

	{
		'walkersumida/fusen.nvim',
		event = "VimEnter",
		opts = {
			keymaps = {
				add_mark = '<leader>me',
				clear_mark = '<leader>mc',
				next_mark = '<leader>]m',
				prev_mark = '<leader>[m',
			},
			annotation_display = {
				mode = 'both',
			},
			sign_priority = 100,
		},
		keys = {
			{ '<leader>ml', '<Cmd>Telescope fusen marks<CR>' },
		},
	},

	{
		'johmsalas/text-case.nvim',
		-- TODO: nnoremap <leader>gac <Cmd>lua vim.fn.setreg("", '_' .. p.textcase.api.to_camel_case(vim.fn.expand('<cword>')))<CR>
		opts = {
			prefix = "<leader>a"
		},
	},

	{
		'windwp/nvim-projectconfig',
		opts = { },
	},

	{
		'ii14/neorepl.nvim',
		cmd = 'Repl',
	},

	'itchyny/lightline.vim',
}
