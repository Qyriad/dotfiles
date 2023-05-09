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

let g:xsh_highlight_all = v:true

let g:NERDCustomDelimiters = { 'dosini': { 'left': '#' }, 'xonsh': { 'left': '#' } }

lua <<EOF
treesitter_configs_setup = {
	ensure_installed = {
		"c",
		"cpp",
		"lua",
		"vim",
		"vimdoc",
		"cmake",
		"python",
		"toml",
		"rust",
	},
	sync_install = false,
	auto_install = true,

	-- Treesitter modules.
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
}
EOF


augroup winenter_whitespaceeol
	autocmd!
	autocmd WinEnter * match Error /\s\+$/
	"autocmd WinEnter * highlight link WhitespaceEOL Error
augroup END

lua << EOF
local use = packer.use
use 'Shirk/vim-gas'
use 'neoclide/jsonc.vim'
use { 'cespare/vim-toml', branch = 'main' }
use 'leafgarland/typescript-vim'
use 'rust-lang/rust.vim'
use 'vim-python/python-syntax'
--use 'Glench/Vim-Jinja2-Syntax'
use 'mitsuhiko/vim-jinja'
use 'Firef0x/PKGBUILD.vim'
use 'chikamichi/mediawiki.vim'
use 'dzeban/vim-log-syntax'
-- use "meatballs/vim-xonsh"
use 'linkinpark342/xonsh-vim'
use 'terminalnode/sway-vim-syntax'
use 'peterhoeg/vim-qml'
use 'LnL7/vim-nix'
use 'nickel-lang/vim-nickel'
use {
	'nvim-treesitter/nvim-treesitter',
	-- Equivalent to `run = ':TSUpdate'` but doesn't fail if the command doesn't exist yet.
	run = function()
		local ts_update = require('nvim-treesitter.install').update {
			with_sync = true,
		}
	end,
	config = function()
		treesitter = require('nvim-treesitter')
		treesitter.configs = require('nvim-treesitter.configs')
		treesitter.configs.setup(treesitter_configs_setup)
	end
}
EOF
