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


augroup winenter_whitespaceeol
	autocmd!
	autocmd WinEnter * match Error /\s\+$/
	"autocmd WinEnter * highlight link WhitespaceEOL Error
augroup END

augroup fix_lua_heredoc
	autocmd!
	autocmd filetype vim syntax clear luaParen
	autocmd filetype vim syntax clear luaParenError
augroup END


lua << EOF
local use = packer.use
use 'Shirk/vim-gas'
use 'neoclide/jsonc.vim'
use { 'cespare/vim-toml', branch = 'main' }
use 'leafgarland/typescript-vim'
use 'rust-lang/rust.vim'
use 'vim-python/python-syntax'
use 'Firef0x/PKGBUILD.vim'
use 'chikamichi/mediawiki.vim'
use 'dzeban/vim-log-syntax'
-- use "meatballs/vim-xonsh"
use 'linkinpark342/xonsh-vim'
use 'terminalnode/sway-vim-syntax'
use 'peterhoeg/vim-qml'
use 'LnL7/vim-nix'
EOF
