"
" Configuration related to Neovim's statusline, which I currently use Lightline to manage.
"


set laststatus=2 " Always show statusline


function! SyntaxItem()
	let synid = synID(line('.'), col('.'), 1)
	let trans = synIDtrans(synid)
	return synIDattr(synid, 'name') . ' | ' . synIDattr(trans, 'name') . ' | ' . synIDattr(trans, 'fg')
endfunction

function! SyntaxColor()
	return ""
	highlight SyntaxItem()
endfunction

function! HomeRelDir()
	let l:dir = fnamemodify(expand('%:p:h'), ':~:.')
	if l:dir ==? substitute(getcwd(), $HOME, '~', 'e')
		return ''
	else
		return l:dir
	endif
endfunction

function! CurrentSymbol()
	if exists('b:coc_current_function')
		return b:coc_current_function
	else
		return ''
	endif
endfunction

function! CurrentTag()
	return tagbar#currenttag('%s', '', 'f')
endfunction

function! LightlineReload()
	call lightline#init()
	call lightline#colorscheme()
	call lightline#update()
endfunction

command! LightlineReload call LightlineReload()


" Core lightline config.
" Gods this looks so much better in lua without vim's line continuation syntax.
lua << EOF
vim.g.lightline = {
	active = {
		left  = {{"mode", "paste"}, {"readonly", "filename", "modified"}, {"zoomed"}},
		--right = {{}, {"dir", "filetype", "lineinfo", "percent", "fileformat", "synitem"}, {}},
		right = {{}, {"dir", "filetype", "lineinfo", "percent", "fileformat"}, {}},
	},
	inactive = {
		left  = {{"readonly", "filename", "modified"}},
		right = {{"lineinfo"}, {"percent"}, {"dir"}},
	},
	--separator = { left = "\ue0b0", right = "\ue0b2" },
	separator = {
		-- Neovim uses lua 5.1, and 5.5 is when lua got unicode literals. Ugh.
		left = "", -- \ue0b0
		right = "" -- \ue0b2
	},
	--separator = { left = utf8.char(0xe0b0), right = utf8.char(0xe0b2) },
	component = { filetype = '%{&ft!=#""?&ft:"no ft"}%<' },
	component_function = { dir = "HomeRelDir", zoomed = "zoom#statusline", synitem = "SyntaxItem" },
	tab = {
		active = {"tabnum", "filename", "modified"},
		inactive = {"tabnum", "filename", "modified"},
	}
}


-- And add lightline to the plugin list while we're at it.
vim.g.plugins = vim.list_extend(vim.g.plugins, {
	'itchyny/lightline.vim',
})
