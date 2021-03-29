scriptencoding utf-8

syntax on
filetype plugin indent on

runtime ftplugin/man.vim

" Each sourced .vim file adds plugins to this list, and we'll install them all at the end.
let g:plugins = []

" Helper functions.
luafile $HOME/.config/nvim/common.lua

source $HOME/.config/nvim/core.vim
source $HOME/.config/nvim/syntax.vim
source $HOME/.config/nvim/lsp.vim
source $HOME/.config/nvim/statusline.vim


""" Other mappings.

" Copy to tmux.
vnoremap <leader>y :Tyank<CR>

" Easy-Align
xmap ga <Plug>(EasyAlign)


" PROBATION:
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

let g:ranger_map_keys = 0
nnoremap <leader>f :RangerCurrentDirectory<CR>


""" Turn the list of plugins into a list of arguments to pass to vim-plug.

" The vimscript version is actually cleaner than the lua version.
" Somehow.

let g:plugin_strings = []

for plugin in g:plugins

	if type(plugin) == v:t_string
		call add(g:plugin_strings, "Plug " . string(plugin))

	elseif type(plugin) == v:t_list

		let actions = ""
		for [k, v] in items(plugin[1])
			let [k, v] = [string(k), string(v)] " Put single quotes around the action-parts.
			let action = ", { " . k . ": " . v . " }" " Of the form `, { 'key': 'value' }`
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
Plug 'junegunn/vim-easy-align'
" Probation:
Plug 'inkarkat/vim-UnconditionalPaste'
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
Plug 'tpope/vim-characterize' " ga

" Display.
Plug 'lifepillar/vim-solarized8'
Plug 'chrisbra/colorizer'
Plug 'luochen1990/rainbow'
Plug 'dhruvasagar/vim-zoom' " <C-w>m

"Plug 'Konfekt/vim-alias'
"Plug 'Shougo/echodoc.vim' " Displays function signatures from completions
"Plug 'thinca/vim-ft-vim_fold'
call plug#end()

" This has to be after the plugin declarations or the colorscheme won't be found.
" As such, the plugins that would normally be added in this file are added above.
source $HOME/.config/nvim/highlight.vim


" vim:textwidth=0
