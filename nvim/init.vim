scriptencoding utf-8

syntax on
filetype plugin indent on

runtime ftplugin/man.vim

" Each sourced .vim file adds plugins to this list, and we'll install them all at the end.
let g:plugins = []
let g:after_plugin_load_callbacks = []

let $CONFIGPATH = stdpath('config')

source $CONFIGPATH/core.vim
source $CONFIGPATH/utils.vim
source $CONFIGPATH/syntax.vim
source $CONFIGPATH/highlight.vim
source $CONFIGPATH/lsp.vim
source $CONFIGPATH/statusline.vim


""" Other mappings.

" Copy to tmux.
vnoremap <leader>y :Tyank<CR>

" Easy-Align
xmap ga <Plug>(EasyAlign)


" PROBATION:
" Word motion makes `word` defined to be more like a variable segment
" I really never use Vim's definition of a `WORD`, so I'll replace its mappings to behave like Vim's original `word`s.
"nnoremap W w
"nnoremap E e
"nnoremap B b
"nnoremap gE ge
"xnoremap W w
"xnoremap E e
"xnoremap B b
"xnoremap gE ge
"onoremap W w
"onoremap E e
"onoremap B b
"onoremap gE ge

"xnoremap aW aw
"xnoremap iW iw

" Also a few <leader> mappings for the same thing, particularly for operator-pending mode
"onoremap <leader>w w
"onoremap <leader>iw iw
"onoremap i<leader>w iw
"onoremap <leader>aw aw
"onoremap a<leader>w aw


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



" Install vim-plug if it isn't already and we're not running as root.
if empty(glob(stdpath("data") . "/autoload/plug.vim")) && $USER !=# "root"
	echomsg 'vim-plug not installed; downloading…'
	" I will do anything to avoid Vim's multiline syntax.
	let s:cmd = "!curl -fLo " . stdpath("data") . "/autoload/plug.vim --create-dirs "
	let s:cmd .= "'https://githubusercontent.com/junegunn/vim-plug/master/plug.vim'"
	execute s:cmd
endif

"let g:coc_global_extensions = ['coc-rust-analyzer', 'coc-jedi', 'coc-vimlsp', 'coc-json', 'coc-lists', 'coc-git']
"let g:coc_global_extensions = ['coc-rust-analyzer', 'coc-pyright', 'coc-vimlsp', 'coc-json', 'coc-lists', 'coc-git']

let g:ranger_map_keys = 0
nnoremap <leader>f :RangerCurrentDirectory<CR>


""" Turn the list of plugins into a list of arguments to pass to vim-plug.

" The vimscript version is actually cleaner than the lua version.
" Somehow.

let g:plugin_strings = []

for s:plugin in g:plugins

	" The simple case: `Plug 'plugin_url`
	if type(s:plugin) == v:t_string
		call add(g:plugin_strings, "Plug " . string(s:plugin))

	" If the plugin was specified as a list, then additional options were specified.
	" Extract them, and turn them into a string into the format vim-plug likes.
	elseif type(s:plugin) == v:t_list

		let s:actions = ""
		for [s:k, s:v] in items(s:plugin[1])
			let [s:k, s:v] = [string(s:k), string(s:v)] " Put single quotes around the action-parts.
			let s:action = ", { " . s:k . ": " . s:v . " }" " Of the form `, { 'key': 'value' }`
			let s:actions .= s:action
		endfor

		call add(g:plugin_strings, "Plug " . string(s:plugin[0]) . s:actions)

	endif
endfor

call plug#begin(stdpath("data") . '/plugged')

" The .vim files sourced above add plugins to this list. Time to tell vim-plug about them!
for i in g:plugin_strings
	execute i
endfor

" Text editing.
Plug 'tmhedberg/SimpylFold' " Python folds.
Plug 'junegunn/vim-easy-align'

" Utilities.
Plug 'tpope/vim-eunuch'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'rbgrouleff/bclose.vim' " Dependency for ranger.vim
Plug 'francoiscabrol/ranger.vim'
Plug 'tpope/vim-tbone' " :Tyank and :Tput
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-characterize' " ga
Plug 'tpope/vim-abolish'
Plug 'gennaro-tedesco/nvim-peekup'

" Display.
Plug 'dhruvasagar/vim-zoom' " <C-w>m

"Plug 'Konfekt/vim-alias'
"Plug 'Shougo/echodoc.vim' " Displays function signatures from completions
"Plug 'thinca/vim-ft-vim_fold'
call plug#end()


for s:callback in g:after_plugin_load_callbacks
	call s:callback()
endfor


" vim:textwidth=0
