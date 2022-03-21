" cSpell:enableCompoundWords

"
" Configuration related to LSP and LSP-like stuff, such as autocompletion and linting.
"


""" Completion

set completeopt=menu,menuone,preview,noselect,noinsert
" Close the popup menu with <Esc>.
inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
" Accept the selected completion with <CR>.
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
" Select the next completion with <Tab>.
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" Select the previous completion with <S-Tab>
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" <C-Space> to force open the completion menu.
inoremap <silent><expr> <C-Space> coc#refresh()


" Non-completion LSP mappings.
nnoremap <silent> <Return> <Cmd>call CocActionAsync('doHover')<CR>
nmap <A-Return> <Plug>(coc-definition)
nmap <A-]> <Plug>(coc-type-definition)
nmap <A-t> <Plug>(coc-type-definition)
nmap <A-[> <Plug>(coc-references)
nmap <A-r> <Plug>(coc-references)

xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

nmap [g <Plug>(coc-git-prevchunk)
nmap ]g <Plug>(coc-git-nextchunk)
nmap gs <Plug>(coc-git-chunkinfo)

nmap [d <Plug>(coc-diagnostic-prev)
nmap ]d <Plug>(coc-diagnostic-next)
nmap gds <Plug>(coc-diagnostic-info)

nmap <leader>gcl <Plug>(coc-codelens-action)
nmap <leader>a <Plug>(coc-codeaction-cursor)

vmap <leader>p  <Plug>(coc-format-selected)

nnoremap <F5> <Cmd>:CocList<CR>
nnoremap <F3> <Cmd>:CtrlPLine<CR>
nnoremap <F4> <Cmd>:CtrlP<CR>
nnoremap <F6> <Cmd>:CtrlPBuffer<CR>
nnoremap <F9> <Cmd>:TagbarToggle<CR>
nnoremap <leader><BS> <Cmd>:pclose<CR>

command! CocFloatHide call coc#util#float_hide()
inoremap <C-l> <Cmd>call coc#util#float_hide()<CR>


" LSP-related highlights.
"highlight link ALEErrorSign Error
"highlight link ALEWarningSign Todo
"highlight CocRustChainingHint guifg=grey


" If we're on our M1 laptop, then we need to tell Pyright to use ARM-Homebrew's Python site-packages.
if hostname() =~? "^keyleth"
	function! AddHomebrewPythonForCoc()
		let l:homebrewPythonSite = "/opt/homebrew/lib/python3.10/site-packages"
		call coc#config("python.analysis.extraPaths", l:homebrewPythonSite)
	endfunction
	call add(g:after_plugin_load_callbacks, function("AddHomebrewPythonForCoc"))
endif


if exists('g:tagbar_sort')
	unlet g:tagbar_sort
endif


" If we're running as root, disable CoC, as it tends to cause… problems.
if $USER ==# "root"
	let g:coc_enabled = 0
endif


function! GetCocConfig(nested_key)
	" Split the key by period, first.
	let l:key_list = split(a:nested_key, '.')

	" The path is the everything but the last segment of the full key.
	let l:path = join(l:key_list[0:-2], '.')

	" The non-nested key is the last segment *only*.
	let l:key = l:key_list[-1]

	" Ask CoC for the configuration dict with that path.
	let l:coc_reply = coc#util#get_config(l:path)

	if !empty(l:coc_reply)
		return l:coc_reply[l:key]
	else
		" However, if CoC didn't give us anything,
		" then try again with the full nested key all at once.
		" And at this point, if CoC still returns {}, then we
		" might as well just return it.
		return coc#util#get_config(a:nested_key)
	endif

endfunction


" cSpell: disable
lua << EOF
vim.g.plugins = vim.list_extend(vim.g.plugins, {
	-- 'do' is a keyword in Lua, so we have to use the arbitrary expression key syntax.
	{ 'neoclide/coc.nvim', { ['do'] = 'yarn install --frozen-lockfile' } },
	{ 'fannheyward/coc-rust-analyzer', { ['do'] = 'yarn install --frozen-lockfile' } },
	{ 'fannheyward/coc-pyright', { ['do'] = 'yarn install --frozen-lockfile' } },
	{ 'neoclide/coc-tsserver', { ['do'] = 'yarn install --frozen-lockfile' } },
	{ 'iamcco/coc-vimlsp', { ['do'] = 'yarn install --frozen-lockfile' } },
	{ 'neoclide/coc-lists', { ['do'] = 'yarn install --frozen-lockfile' } },
	{ 'neoclide/coc-git', { ['do'] = 'yarn install --frozen-lockfile' } },
	{ 'iamcco/coc-spell-checker', { ['do'] = 'yarn install --frozen-lockfile' } },
	'liuchengxu/vista.vim',
	'majutsushi/tagbar',
})
EOF
