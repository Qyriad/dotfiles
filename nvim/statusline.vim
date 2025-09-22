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

lua << EOF
function lsp_status_info()
	if lsp_status ~= nil then
		return lsp_status.status()
	else
		return ""
	end
end

--LAST_PROGRESS = { }

vim.api.nvim_create_autocmd('LspProgress', {
	---@param tbl { id: integer, event: string, data: any }
	callback = function(tbl)
		-- TODO: maybe use a custom popup window
		vim.print(vim.lsp.status())
		--LAST_PROGRESS_ID = vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
		--	title = string.format("LSP Status for client %d", tbl.data.client_id),
		--	timeout = 500,
		--	replace = LAST_PROGRESS.id or nil,
		--	hide_from_history = true,
		--})
	end,
})

vim.api.nvim_create_autocmd('LspNotify', {
	callback = function(tbl)
		--vim.print(tbl.data.method)
	end
})
EOF

function! LspStatus() abort
	return v:lua.lsp_status_info()
endfunction

function! LightlineReload()
	call lightline#init()
	call lightline#colorscheme()
	call lightline#update()
endfunction

command! LightlineReload call LightlineReload()

lua << EOF
function tagstack()
	local stack = vim.fn.gettagstack()
	local results = { }
	for i, tag_item in ipairs(stack.items) do
		if i > stack.curidx then
			break
		end
		table.insert(results, tag_item.tagname)
	end
	return vim.fn.join(results, "/")
end
EOF

function Tagstack() abort
	return v:lua.tagstack()
endfunction


" Core lightline config.
" Gods this looks so much better in lua without vim's line continuation syntax.
lua << EOF
vim.g.lightline = {
	active = {
		left  = {{"mode", "paste"}, {"readonly", "filename", "modified"}, {"zoomed"}},
		right = {{}, {"dir", "filetype", "lineinfo", "percent", "fileformat"}, {"lspstatus"}},
	},
	inactive = {
		left  = {{"readonly", "filename", "modified"}},
		right = {{"lineinfo"}, {"percent"}, {"dir"}},
	},
	separator = {
		-- Lua 5.5 is when Lua got \uxxxx escapes, but Lua 5.3 has \u{xx..} style escapes, and
		-- LuaJIT implements Lua 5.1 that extension from 5.3.
		left = "\u{e0b0}",
		right = "\u{e0b2}",
	},
	--separator = { left = utf8.char(0xe0b0), right = utf8.char(0xe0b2) },
	component = { filetype = '%{&ft!=#""?&ft:"no ft"}%<' },
	component_function = {
		dir = "HomeRelDir",
		zoomed = "zoom#statusline",
		synitem = "SyntaxItem",
		--tagstack = "LspStatus",
		lspstatus = "LspStatus",
	},
	--tabline = {
	--	right = {{ 'LspProgress' }},
	--},
	--tab = {
	--	active = {"tabnum", "filename", "modified", 'Symbol'},
	--	inactive = {"tabnum", "filename", "modified"},
	--}
}


-- And add lightline to the plugin list while we're at it.
use 'itchyny/lightline.vim'
use 'nvim-lualine/lualine.nvim'
EOF
