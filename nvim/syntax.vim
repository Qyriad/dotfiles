"
" Configuration of Neovim-builtin syntax stuff.
"

" Fold augroups, functions, Lua, and Python
let g:vimsyn_folding = 'aflP'
" Support embedded Lua and Python.
let g:vimsyn_embed = 'lP'

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

let g:NERDCustomDelimiters = { 'dosini': { 'left': '#' }, 'xonsh': { 'left': '#' } }

lua << EOF
vim.g.plugins = vim_list_cat(vim.g.plugins, {
	'Shirk/vim-gas',
	'neoclide/jsonc.vim',
	'leafgarland/typescript-vim',
	'rust-lang/rust.vim',
	'vim-python/python-syntax',
	'Firef0x/PKGBUILD.vim',
	'chikamichi/mediawiki.vim',
	'dzeban/vim-log-syntax',
	--"meatballs/vim-xonsh",
	'linkinpark342/xonsh-vim',
	'terminalnode/sway-vim-syntax',
})
EOF
