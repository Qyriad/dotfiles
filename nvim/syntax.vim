"
" Configuration of Neovim-builtin syntax stuff.
"

" Highlighted as an error in our colorscheme.
match TrailingWhitespace /\s\+$/

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

let g:markdown_syntax_conceal = 1

" Fuck off.
let g:zig_fmt_autosave = v:false

lua <<EOF
vim.g.python_indent = {
	closed_paren_align_last_line = false,
	open_paren = "shiftwidth()",
	continue = "shiftwidth()",
	disable_parentheses_indenting = true,
}
EOF

let g:xsh_highlight_all = v:true

nnoremap <leader>T <Cmd>lua vim.treesitter.dev.inspect_tree { command = "vnew" }<CR>
nnoremap <leader>I <Cmd>Inspect<CR>

function! SynNameStack() abort
	return synstack(line('.'), col('.'))->copy()->map({key, value -> value->synIDattr('name')})
endfunction

command! SynNameStack echomsg SynNameStack()

" Allow us to `let b/w/t/g:cpp = v:true` to make `.h` files count as C++.
" FIXME: this needs a better name
let g:cpp = v:false
function! MaybeCppHeaders() abort
	if get(b:, 'cpp', get(w:, 'cpp', get(t:, 'cpp', get(g:, 'cpp', v:false))))
		set filetype=cpp
	endif
endfunction

augroup CppHeaders
	autocmd! BufRead,BufNewFile *.h call MaybeCppHeaders()
augroup END

" NOTE: In Rust, "@class" is each "item".
nnoremap ]c <Cmd>TSTextobjectGotoNextEnd @class.outer<CR>
xnoremap ]c <Cmd>TSTextobjectGotoNextEnd @class.outer<CR>
nnoremap [c <Cmd>TSTextobjectGotoPreviousStart @class.outer<CR>
xnoremap [c <Cmd>TSTextobjectGotoPreviousStart @class.outer<CR>

nnoremap ]f <Cmd>TSTextobjectGotoNextEnd @function.inner<CR>
xnoremap ]f <Cmd>TSTextobjectGotoNextEnd @function.inner<CR>
nnoremap [f <Cmd>TSTextobjectGotoPreviousStart @function.inner<CR>
xnoremap [f <Cmd>TSTextobjectGotoPreviousStart @function.inner<CR>

lua <<EOF
vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		local amatch = ev.amatch
		if amatch == "qf" then
			vim.treesitter.stop(ev.buf)
			return
		end
		pcall(function()
			local ts_enabled = vim.b[ev.buf].treesitter
			if ts_enabled ~= false then
				vim.treesitter.start(ev.buf)
			else
				--vim.treesitter.stop(ev.buf)
				-- idk why this needs the defer but it seems to.
				vim.defer_fn(function() vim.treesitter.stop(ev.buf) end, 1)
				vim.bo[ev.buf].syntax = 'ON'
			end
		end)
	end,
})
treesitter_configs_setup = {
	sync_install = false,
	auto_install = false,

	-- Treesitter modules.
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	indent = {
		enable = false,
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

augroup ReapplyEditorconfig
	autocmd! FileType * doautocmd nvim.editorconfig BufRead
augroup END

lua << EOF
--use 'Glench/Vim-Jinja2-Syntax'
--use 'mitsuhiko/vim-jinja'
-- use "meatballs/vim-xonsh"
--use {
--	'nvim-treesitter/nvim-treesitter',
--	branch = "main",
--	lazy = false,
--	--build = ":TSUpdate",
--	dependencies = {
--		'JoosepAlviste/nvim-ts-context-commentstring',
--	},
--	config = function()
--		treesitter = require('nvim-treesitter')
--		--treesitter.configs = require('nvim-treesitter.configs')
--		--treesitter.install = require('nvim-treesitter.install')
--		--treesitter.utils = require('nvim-treesitter.utils')
--		--treesitter.info = require('nvim-treesitter.info')
--		--treesitter.configs.setup(treesitter_configs_setup)
--	end,
--}
--use {
--	'romus204/tree-sitter-manager.nvim',
--	opts = qyriad.nested_tbl {
--		-- These are the default, but we are spelling them out explicitly so we don't forget.
--		parser_dir = vim.fn.stdpath('data') .. '/site/parser',
--		query_dir = vim.fn.stdpath('data') .. '/site/queries',
--
--		languages = {
--			numbat = {
--				install_info = {
--					url = 'https://github.com/irevoire/tree-sitter-numbat',
--					queries = 'queries',
--				},
--			},
--			xonsh = {
--				install_info = {
--					url = 'https://github.com/FoamScience/tree-sitter-xonsh',
--					queries = 'queries',
--				},
--			},
--		},
--	},
--}
EOF
