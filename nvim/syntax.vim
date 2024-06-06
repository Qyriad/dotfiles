"
" Configuration of Neovim-builtin syntax stuff.
"

" Fold augroups, functions, Lua, and Python
let g:vimsyn_folding = 'aflP'
" Support embedded Lua and Python.
let g:vimsyn_embed = 'lP'
let g:vimsyn_noerror = 1

" Highlight whitespace errors.
let g:c_space_errors = 1
let g:python_space_error_highlight = 1

let g:python_highlight_builtins = 1
let g:python_highlight_builtin_funcs = 1
let g:python_highlight_builtin_types = 1
let g:python_highlight_exceptions = 1
let g:python_highlight_string_formatting = 1
let g:python_highlight_string_format = 1
let g:python_highlight_indent_errors = 1
let g:python_highlight_space_errors = 1
let g:python_highlight_class_vars = 1
"let g:python_highlight_func_calls = 1

lua <<EOF
vim.g.python_indent = {
	closed_paren_align_last_line = false,
	open_paren = "shiftwidth()",
	continue = "shiftwidth()",
	disable_parentheses_indenting = true,
}
EOF

let g:xsh_highlight_all = v:true

let g:NERDCustomDelimiters = { 'dosini': { 'left': '#' }, 'xonsh': { 'left': '#' } }

function! SynNameStack() abort
	return synstack(line('.'), col('.'))->copy()->map({key, value -> value->synIDattr('name')})
endfunction

command! SynNameStack echomsg SynNameStack()

lua <<EOF
treesitter_configs_setup = {
	sync_install = false,
	auto_install = false,

	-- Treesitter modules.
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	indent = {
		enable = true,
	},
	autotag = {
		enable = true,
	},
	textobjects = {
		move = {
			enable = true,
			goto_next_start = {
				["]]"] = { query = { "@function.inner", "@class.inner", '@block.inner' } },
				[']p'] = { query = { '@parameter.inner' } },
			},
			goto_previous_start = {
				["[["] = { query = { "@function.inner", "@class.inner", '@block.inner' } },
				['[p'] = { query = { '@parameter.inner' } },
			},
		},
		select = {
			enable = true,
			keymaps = {
				ip = '@parameter.inner',
				ap = '@parameter.outer',
				ib = '@block.inner',
				ab = '@block.outer',
			},
		},
	},
	context_commentstring = true,
}
EOF


augroup winenter_whitespaceeol
	autocmd!
	autocmd WinEnter * match Error /\s\+$/
	"autocmd WinEnter * highlight link WhitespaceEOL Error
augroup END

lua << EOF
use { 'Shirk/vim-gas', ft = "gas" }
use { 'neoclide/jsonc.vim', ft = "jsonc" }
use { 'cespare/vim-toml', branch = 'main' }
use { 'leafgarland/typescript-vim', ft = "typescript" }
use { 'rust-lang/rust.vim', ft = "rust" }
--use 'Glench/Vim-Jinja2-Syntax'
--use 'mitsuhiko/vim-jinja'
use { 'Firef0x/PKGBUILD.vim', ft = "PKGBUILD" }
use { 'chikamichi/mediawiki.vim', ft = "mediawiki" }
use { 'dzeban/vim-log-syntax', ft = "log" }
-- use "meatballs/vim-xonsh"
use { 'linkinpark342/xonsh-vim', ft = "xonsh" }
use { 'terminalnode/sway-vim-syntax', ft = "swayconfig" }
use { 'peterhoeg/vim-qml', ft = "qml" }
use { 'nickel-lang/vim-nickel', ft = "nickel" }
use {
	'nvim-treesitter/nvim-treesitter',
	lazy = false,
	--build = ":TSUpdate",
	dependencies = {
		'JoosepAlviste/nvim-ts-context-commentstring',
	},
	config = function()
		treesitter = require('nvim-treesitter')
		treesitter.configs = require('nvim-treesitter.configs')
		treesitter.install = require('nvim-treesitter.install')
		treesitter.utils = require('nvim-treesitter.utils')
		treesitter.info = require('nvim-treesitter.info')
		treesitter.configs.setup(treesitter_configs_setup)
	end,
}
use {
	'IndianBoy42/tree-sitter-just',
	ft = "just",
	opts = {},
}
use {
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
}
use {
	'nvim-treesitter/nvim-treesitter-context',
	lazy = false,
	opts = {
		max_lines = 3,
	},
}
use {
	'JoosepAlviste/nvim-ts-context-commentstring',
	lazy = false,
}
use {
	'nvim-treesitter/nvim-treesitter-textobjects',
	after = 'nvim-treesitter',
}

EOF
