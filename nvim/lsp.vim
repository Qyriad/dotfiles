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



if exists('g:tagbar_sort')
	unlet g:tagbar_sort
endif


lua << EOF
vim.g.plugins = vim_list_cat(vim.g.plugins, {
	-- 'do' is a keyword in Lua, so we have to use the arbitrary expression key syntax.
	{ 'neoclide/coc.nvim', { ['do'] = 'yarn install --frozen-lockfile' } },
	'liuchengxu/vista.vim',
	'majutsushi/tagbar'
})
EOF
