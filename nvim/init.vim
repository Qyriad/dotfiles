scriptencoding utf-8

syntax on
filetype plugin indent on

runtime ftplugin/man.vim

" Each .vim file adds plugins to this list, and we'll install them all at the end.
let g:plugins = []

" Helper functions.
luafile $HOME/.config/nvim/common.lua

source $HOME/.config/nvim/core.vim

source $HOME/.config/nvim/syntax.vim

source $HOME/.config/nvim/lsp.vim

" Linting
"highlight link ALEErrorSign Error
"highlight link ALEWarningSign Todo
"highlight CocRustChainingHint guifg=grey


""" Mapping helper functions

function! BufSel(pattern)
	let bufcount = bufnr('$')
	let currbufnr = 1
	let nummatches = 0
	let firstmatchingbufnr = 0
	while currbufnr <= bufcount
		if(bufexists(currbufnr))
			let currbufname = bufname(currbufnr)
			if(match(currbufname, a:pattern) > -1)
				echo currbufnr . ': ' . bufname(currbufnr)
				let nummatches += 1
				let firstmatchingbufnr = currbufnr
			endif
		endif
		let currbufnr = currbufnr + 1
	endwhile
	if(nummatches == 1)
		execute ':buffer ' . firstmatchingbufnr
	elseif(nummatches > 1)
		let desiredbufnr = input('Enter buffer number: ')
		if(strlen(desiredbufnr) != 0)
			execute ':buffer ' . desiredbufnr
		endif
	else
		echo 'No matching buffers'
	endif
endfunction

command! -nargs=1 Bs :call BufSel('<args>')


""" Autocommands

augroup disable_rainbow_cmake
	autocmd! FileType cmake,mediawiki,tvtropes RainbowToggleOff
augroup END


" Mappings

" Copy to tmux.
vnoremap <leader>y :Tyank<CR>

" Switch buffer
nnoremap <leader>sb <Cmd>Bs<CR>

" Easy-Align
xmap ga <Plug>(EasyAlign)

" Word motion makes `word` defined to be more like a variable segment
" I really never use Vim's definition of a `WORD`, so I'll replace its mappings to behave like Vim's original `word`s.
nnoremap W w
nnoremap E e
nnoremap B b
nnoremap gE ge
xnoremap W w
xnoremap E e
xnoremap B b
xnoremap gE ge
onoremap W w
onoremap E e
onoremap B b
onoremap gE ge

xnoremap aW aw
xnoremap iW iw

" Also a few <leader> mappings for the same thing, particularly for operator-pending mode
onoremap <leader>w w
onoremap <leader>iw iw
onoremap i<leader>w iw
onoremap <leader>aw aw
onoremap a<leader>w aw


" Capitalize the last inserted text
function! Capitalize_and_return()
	normal `[v`]gU`]
	silent s/-/_/
	normal ``a
endfunction

" Usable from <C-o>
nnoremap <leader>c :normal `[v`]gU`]a<CR>
" Usable from insert mode, and replaces - with _
inoremap <F3> <C-o>:call Capitalize_and_return()<CR>


" Statusline/lightline
set laststatus=2 " Always show statusline

" Lightline
source $HOME/.config/nvim/statusline.vim
"let g:lightline = { 'active': {}, 'inactive': {}, 'tab': { 'active': {}, 'inactive': {} } }
"let g:lightline.active.left = [['mode', 'paste'], ['readonly', 'filename', 'modified'], ['zoomed']]
"let g:lightline.active.right = [[], ['dir', 'filetype', 'lineinfo', 'percent', 'fileformat'], []]
""let g:lightline.active.right': [[], ['dir', 'filetype', 'lineinfo', 'percent', 'fileformat'], ['tag', 'syn']]
"let g:lightline.inactive.left = [['readonly', 'filename', 'modified']]
"let g:lightline.inactive.right = [['lineinfo'], ['percent'], ['dir']]
"let g:lightline.separator = { 'left': "\ue0b0", 'right': "\ue0b2" }
"let g:lightline.component = { 'filetype': '%{&ft!=#""?&ft:"no ft"}%<' }
"let g:lightline.component_function = { 'dir': 'HomeRelDir', 'zoomed': 'zoom#statusline' }
""let g:lightline.component_function = { 'syn': 'SyntaxItem', 'dir': 'HomeRelDir', 'symbol': 'CurrentSymbol', 'zoomed': 'zoom#statusline', 'tag': 'CurrentTag' },
"let g:lightline.tab.active = ['tabnum', 'filename', 'modified']
"let g:lightline.tab.inactive = ['tabnum', 'filename', 'modified']

"let g:lightline.colorscheme = 'embark'

" vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
	echomsg 'vim-plug not installed; downloading…'
	!curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	augroup vim_plug
		autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
	augroup END
endif

"let g:coc_global_extensions = ['coc-rust-analyzer', 'coc-jedi', 'coc-vimlsp', 'coc-json', 'coc-lists', 'coc-git']
let g:coc_global_extensions = ['coc-rust-analyzer', 'coc-pyright', 'coc-vimlsp', 'coc-json', 'coc-lists', 'coc-git']

let g:plugin_strings = []

lua << EOF
--vim.g.plugins = vim_list_cat(vim.g.plugins, {
--	"tpope/vim-surround",
--	{ "neoclide/coc.nvim", { ['do'] = 'yarn install --frozen lockfile' } }
--})
--local plugin_strings = { }
--for i = 1, #vim.g.plugins do
--	local current_plugin = vim.g.plugins[i]
--	if current_plugin[2] == nil then
--		table.insert(plugin_strings, "Plug '" .. current_plugin .. "'")
--	else
--		local actions = ""
--		for k, v in pairs(current_plugin[2]) do
--			actions = actions .. ", { '" .. k .. "': '" .. v .. "' }"
--		end
--		table.insert(plugin_strings, "Plug '" .. current_plugin[1] .. "'" .. actions)
--	end
--end
--vim.g.plugin_strings = plugin_strings
EOF

" The vimscript version is actually cleaner than the lua version.
" Somehow.
for plugin in g:plugins

	if type(plugin) == v:t_string
		call add(g:plugin_strings, "Plug " . string(plugin))

	elseif type(plugin) == v:t_list

		let actions = ""
		for [k, v] in items(plugin[1])
			let k = string(k)
			let v = string(v)
			let action = ", { " . k . ": " . v . " }"
			let actions .= action
		endfor

		call add(g:plugin_strings, "Plug " . string(plugin[0]) . actions)

	endif
endfor

call plug#begin('~/.config/nvim/plugged')

" The .vim files sourced above add plugins to this list. Time to tell vim-plug about them!
for i in g:plugin_strings
	execute i
endfor

" Text editing.
Plug 'tmhedberg/SimpylFold' " Python folds.
Plug 'inkarkat/vim-UnconditionalPaste'
Plug 'junegunn/vim-easy-align'
Plug 'chaoren/vim-wordmotion'
Plug 'gaving/vim-textobj-argument'
Plug 'michaeljsmith/vim-indent-object'
Plug 'terryma/vim-expand-region'
Plug 'bergercookie/vim-debugstring'
Plug 'mbbill/undotree'

" Utilities.
Plug 'tpope/vim-eunuch'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'rbgrouleff/bclose.vim' " Dependency for ranger.vim
Plug 'francoiscabrol/ranger.vim'
Plug 'tpope/vim-tbone' " :Tyank and :Tput
Plug 'tpope/vim-fugitive'

" Display.
"Plug 'itchyny/lightline.vim'
Plug 'lifepillar/vim-solarized8'
Plug 'chrisbra/colorizer'
Plug 'luochen1990/rainbow'
Plug 'dhruvasagar/vim-zoom' " <C-w>m

"Plug 'tpope/vim-characterize'
"Plug 'Konfekt/vim-alias'
"Plug 'Shougo/echodoc.vim' " Displays function signatures from completions
"Plug 'thinca/vim-ft-vim_fold'
call plug#end()

" This has to be after the plugin delcarations or the colorscheme won't be found.
" As such, the plugins that would normally be added in this file are added above.
source $HOME/.config/nvim/highlight.vim


" vim:textwidth=0
