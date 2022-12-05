" cSpell:enableCompoundWords

"
" Configuration related to LSP and LSP-like stuff, such as autocompletion and linting.
"


""" Completion

function! CheckBackspace() abort
	let l:col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction

set completeopt=menu,menuone,preview,noselect,noinsert
" Close the popup menu with <Esc>.
"inoremap <expr> <Esc> coc#pum#visible() ? "\<C-e>" : "\<Esc>"
" Accept the selected completion with <CR>.
inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
" Select the next completion with <Tab>.
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : CheckBackspace() ? "\<Tab>" : coc#refresh()

" Select the previous completion with <S-Tab>
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

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

nnoremap <M-p> <Cmd>:CocList commands<CR>
nnoremap <F5> <Cmd>:CocList<CR>
nnoremap <F3> <Cmd>:CtrlPLine<CR>
nnoremap <F4> <Cmd>:CtrlP<CR>
nnoremap <F6> <Cmd>:CtrlPBuffer<CR>
nnoremap <F9> <Cmd>:TagbarToggle<CR>
nnoremap <leader><BS> <Cmd>:pclose<CR>

command! CocFloatHide call coc#float#close_all()
inoremap <C-l> <Cmd>call coc#float#close_all()<CR>
nnoremap <leader><C-l> <Cmd>call coc#float#close_all()<CR>
nnoremap <leader><esc> <Cmd>CocFloatHide<CR>
inoremap <leader><esc> <Cmd>CocFloatHide<CR>


" LSP-related highlights.
" These must be after the `:colorscheme` call in syntax.vim.
highlight! link CocSemComment SpecialComment
highlight! link CocMenuSel PmenuSel
"highlight link ALEErrorSign Error
"highlight link ALEWarningSign Todo
"highlight CocRustChainingHint guifg=grey


if exists('g:tagbar_sort')
	unlet g:tagbar_sort
endif


" If we're running as root, disable CoC, as it tends to cause… problems.
if $USER ==# "root"
	let g:coc_enabled = 0
endif


function! GetCocConfig(nested_key)
	" Split the key by period, first.
	let l:key_list = split(a:nested_key, '\.')

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


function! StructsOnly(key, value)
	if a:value.kind ==? 'struct'
		return v:true
	endif
	return v:false
endfunction


function! PosLtEq(pos1, pos2)
	if a:pos1.line == a:pos2.line
		return a:pos1.column <= a:pos2.column
	endif
	return a:pos1.line <= a:pos2.line
endfunction

function! PosGtEq(pos1, pos2)
	"if a:pos1.line == a:pos2.line
		"return a:pos1.column >= a:pos2.column
	"endif
	return a:pos1.line >= a:pos2.line
endfunction

function! Pos2InPos1(pos1, pos2)
	return PosLtEq(pos2, pos1)
endfunction


function! ContainsCursor(key, value)
	let l:cursor_pos = { 'line': line('.'), 'column': col('.') }
	let l:start = { 'line': a:value.range.start.line, 'column': a:value.range.start.character->str2nr() }
	let l:end = { 'line': a:value.range.end.line, 'column': a:value.range.end.character->str2nr() }
	"echomsg 'Start: '
	"echomsg l:start
	"echomsg 'End: '
	"echomsg l:end
	"echomsg 'FOR: '
	"echomsg l:start
	"echomsg l:cursor_pos
	"echomsg l:end
	"echomsg PosLtEq(l:start, l:cursor_pos) && PosGtEq(l:end, l:cursor_pos)
	"echomsg PosGtEq(l:end, l:cursor_pos)
	return PosLtEq(l:start, l:cursor_pos) && PosGtEq(l:end, l:cursor_pos)


	"let l:current_line = line('.')
	"let l:current_col = col('.')
	"let l:start = a:value.range.start
	"let l:end = a:value.range.end
	"if l:current_line == l:start.line
		"return l:current_col >= l:
	"endif
	"if l:current_line >= l:start.line &&
	"if l:current_line >= a:value.range.start.line && l:current_line <= a:value.range.end.line
		"return v:true
	"endif
	"return v:false
endfunction


function! NearbySymbols()
	if &runtimepath =~# 'coc.nvim' && g:coc_service_initialized && CocHasProvider('documentSymbol')
		let l:doc_symbols = coc#rpc#request('documentSymbols', [bufnr()])
		return filter(l:doc_symbols, funcref("ContainsCursor"))
	endif
	return []
endfunction


function! SymbolHierarchy()
	"if &runtimepath =~# 'coc.nvim' && CocHasProvider('documentSymbol')
	"if &runtimepath =~# 'coc.nvim' && coc#rpc#ready() && CocHasProvider('documentSymbol')
	if &runtimepath =~# 'coc.nvim' && g:coc_service_initialized && CocHasProvider('documentSymbol')
		let l:doc_symbols = coc#rpc#request('documentSymbols', [bufnr()])

		let l:containers = filter(l:doc_symbols, funcref("ContainsCursor"))
		"return map(l:containers, { key, val -> val.text }), ''
		"echomsg len(l:containers)
		return map(l:containers, { key, val -> val.text })
		"let l:ret = map(l:containers, { key, val -> val.text })
		"let l:ret += [""]
		"return l:ret
	endif
	return ''
endfunction

function! SymbolExpanded()
	"return [ split(SymbolHierarchy(), '') ]
	"return [reverse(SymbolHierarchy()), [], []]
	return [[], [expand('%:t')] + SymbolHierarchy(), []]
	"return ['left', 'middle', 'right']
endfunction


" cSpell: disable
lua << EOF
local use = packer.use
use {
	'neoclide/coc.nvim',
	run = 'yarn install --frozen-lockfile',
	config = function()
		-- If we're on our M1 laptop, then we need to tell Pyright to use ARM-Homebrew's Python site-packages.
		if string.lower(vim.fn.hostname()) == "keyleth" then
			vim.fn["coc#config"](
				"python.analysis.extraPaths",
				"/opt/homebrew/lib/python3.10/site-packages"
			)
		end
	end
}
use { 'fannheyward/coc-rust-analyzer', run = 'yarn install --frozen-lockfile' }
use { 'fannheyward/coc-pyright', run = 'yarn install --frozen-lockfile' }
use { 'neoclide/coc-tsserver', run = 'yarn install --frozen-lockfile' }
use { 'iamcco/coc-vimlsp', run = 'yarn install --frozen-lockfile' }
use { 'josa42/coc-go', run = 'yarn install --frozen-lockfile' }
use { 'neoclide/coc-json', run = 'yarn install --frozen-lockfile' }
use { 'neoclide/coc-lists', run = 'yarn install --frozen-lockfile' }
use { 'neoclide/coc-git', run = 'yarn install --frozen-lockfile' }
use { 'iamcco/coc-spell-checker', run = 'yarn install --frozen-lockfile' }
use { 'clangd/coc-clangd', run = 'yarn install --frozen-lockfile' }
use 'liuchengxu/vista.vim'
use 'majutsushi/tagbar'
EOF
