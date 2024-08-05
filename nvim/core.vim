"
" Core Neovim configuration. I don't want to use Neovim without most of these.
" You can pry this file from my cold dead hands.
"

scriptencoding utf-8

""" Options
set number " Show line numbers.
set modeline " Allow vim commands in text file comments.
set undofile " Persistent undo tree.
set incsearch " Incremental search.
set tabstop=4 " Number of visual spaces to be displayed per HT.
set noexpandtab " Don't 'expand' tabs to spaces by default.
set shiftwidth=0 " Use tabstop value for indenting.
set softtabstop=-1 " Use tabstop value for expanded tabs too.
set showcmd " Show the last command on the command line.
set lazyredraw " Only redraw when we need to.
set scrolloff=2 " Keep 2 lines between the end of the buffer and the cursor.
set sidescrolloff=2 " Keep 2 characters between the current column and the screen edge.
set mouse=n " Enable the mouse in normal mode.
" This is how many characters I can fit on one line if I have a vertical split.
set colorcolumn=115
set cursorline " Highlight the line our cursor is on.
set signcolumn=number " Show signs in the number column.
set textwidth=120 " Wrap text at 120 chracters by default.
set wrap " Visually wrap lines.
set linebreak " Only wrap on word boundaries.
set breakindent " Indent soft wrapped lines.
" Show 'showbreak' value before the soft-indentation, rather than after.
" And further 'indent' the soft-indentation by an extra four spaces.
set breakindentopt=sbr,shift:4
let &showbreak = "\u21f8" " `⇸` as an indicator to show at the beginning of visually wrapped lines.
set showtabline=2 " Always show the tabline, even if there's only one tab.
set wildmenu " Tab-complete command menu.
set wildmode=longest:full,full " Most bash-like way.
set wildignorecase " Ignore case when completing.
set wildcharm=<C-i> " Allow tab to autocomplete in mappings.
set timeoutlen=1000 ttimeoutlen=10 " Remove <Esc> leaving insert mode delay in Tmux.
set splitright " Make :vsplit put the new window on the right.
set splitbelow " Make :split put the new window on the bottom.
set selection=old " Make visual mode respect 'virtualedit' setting.
set foldlevel=10 " Don't fold almost anything by default.
set hidden " Allow for hidden, modified but not written buffers.
set bufhidden=hide " Hide buffers instead of deleting or unloading them.
set ignorecase
set smartcase
set gdefault " Substitute all matches in a line by default.
" Indent case blocks and Java anonymous classes correctly.
" Indent one extra level for function definition continuation.
" Same but for function calls.
set cinoptions=l1,j1,(4,W4
" Autowrap comments using textwidth, inserting the comment leader,
" and remove the comment leader when joining lines when it makes sense.
set formatoptions=cj
" Don't display . on folds.
let &fillchars = "fold: "
" Use » to indicate tabs, a - for trailing whitespace, and · for multiple leading spaces.
set list
let &listchars = "tab:\u00bb ,trail:-,nbsp:+,leadmultispace:\u00b7"
set diffopt=algorithm:patience
set fsync " Syncs the filesystem after :write.


set updatetime=1000 "Lets languageservers update faster, and shortens the time for CursorHold.
set noshowmode " We're using lightline, so showing the mode in the command line is redundant.

let &grepprg = 'rg --vimgrep --no-heading --smart-case'
nnoremap <leader>g :Notify lgrep<Space>


""" Slow down mouse scroll speed.
" This is intended for macOS touchpads, but ideally the solution should be
" in the terminal instead. I just need to figure that out >.>
if hostname() =~? "^keyleth"
	noremap <ScrollWheelUp> <C-y>
	noremap <ScrollWheelDown> <C-e>
endif


"""
""" Core autocommands
"""


""" Restore last cursor position when opening a file.
function! Restore_last_position()
	if &filetype =~# 'gitcommit'
		return
	endif

	let l:last_position = line("'\"")
	if l:last_position != 0 && l:last_position <= line("$")
		normal! g`"
	endif
endfunction

augroup restore_last_position
	autocmd! BufWinEnter * call Restore_last_position()
augroup END


" Turn off hlsearch when entering insert mode.
augroup insert_nohlsearch
	autocmd! InsertEnter * nohlsearch
augroup END

function! PagerMode() abort
	nnoremap <buffer> J <C-e>j
	nnoremap <buffer> K <C-y>k
endfunction

function! NoPagerMode() abort
	silent nunmap <buffer> J
	silent nunmap <buffer> K
endfunction

command! PagerMode call PagerMode()
command! NoPagerMode call NoPagerMode()

" When modifiable is off, we're probably using Neovim like a pager.
" Use capital J and K to move the cursor and the screen at the same time.
augroup PagerMode
	autocmd!
	autocmd OptionSet modifiable if v:option_new == v:false | call PagerMode() | endif
	"autocmd OptionSet modifiable if v:option_new == v:true | call NoPagerMode() | endif
augroup END


""" Filetype overrides.

let g:c_syntax_for_h = 1

" FIXME: migrate to ftdetect.
augroup gas_ft
	autocmd! BufRead,BufNewFile *.S set filetype=gas
augroup END


""" Spellcheck.
" Notes on spellcheck for me:
" zg to add word to dictionary
" z= to open suggestion list
augroup spellcheck
	autocmd! FileType gitcommit,markdown,text setlocal spell spelllang=en_us spellcapcheck=
augroup END
" Note: spell check is also explicitly disabled in after/ftplugin/xonsh.vim

""" Core mappings.

" Use backslash as a leader.
let mapleader="\\"

" Save my pinky.
nnoremap ; :

" ...But sometimes I actually want to use ;
nnoremap <leader>; ;

" I keep accidentially closing Neovim when I just want to write.
" I don't need :wq. If I want to write and quit, I'll just :w and :q separately.
cnoreabbrev wq w
command! Wq wq

" Use line-wrapped movement by default, but specifying a count disables it.
nnoremap <expr> j (v:count > 0 ? "m'" . v:count . 'j' : 'gj')
nnoremap <expr> k (v:count > 0 ? "m'" . v:count . 'k' : 'gk')

" Stop highlighting last search with \/
nnoremap <leader>/ <Cmd>nohlsearch<CR>

" Have the visual-selection indent commands re-highlight the last visual selection after indenting.
vnoremap > >gv
vnoremap < <gv

" gp to select last pasted text.
nnoremap gp `[v`]

" unmap Q
nnoremap Q <nop>

" <A-BS> to kill-word.
inoremap <A-BS> <C-w>
cnoremap <A-BS> <C-w>

" <A-Left> and <A-Right> to backwards-word and forwards-word
" This uses Neovim's builtin <S-Left> command.
inoremap <A-Left> <S-Left>
cnoremap <A-Left> <S-Left>
inoremap <A-Right> <S-Right>
cnoremap <A-Right> <S-Right>

" Add newlines above/below without entering insert mode or moving the cursor.
nnoremap <leader>o mzo<Esc>`z
nnoremap <leader>O mzO<Esc>`z

" Add newline at the current position without entering insert mode or moving the cursor.
nnoremap <leader><CR> mzi<CR><Esc>`z

" Reverse join. That is to say, move the rest of the current line to the above line.
" Useful for moving comments to their own line.
nnoremap <leader>J mzr<CR>ddkP`z

" Make <C-f> and <C-b> scroll 11 instead, by default.
nnoremap <C-f> 11<c-e>
nnoremap <C-b> 11<C-y>

" Tired:
function! SwitchSourceHeader() abort
	let l:ext = expand("%:e")
	let l:stem = expand("%:r")
	if ["c", "cpp", "cxx", "cc"]->index(l:ext)
		if filereadable(l:stem .. ".hh")
			execute printf("edit %s", l:stem .. ".hh")
		elseif filereadable(l:stem .. ".hpp")
			execute printf("edit %s", l:stem .. ".hpp")
		elseif filereadable(l:stem .. ".h")
			execute printf("edit %s", l:stem .. ".h")
		endif
	else
		if filereadable(l:stem .. ".cc")
			execute printf("edit %s", l:stem .. ".cc")
		elseif filereadable(l:stem .. ".cpp")
			execute printf("edit %s", l:stem .. ".cpp")
		elseif filereadable(l:stem .. ".c")
			execute printf("edit %s", l:stem .. ".c")
		endif
	endif
	echomsg "No matching header file found"
endfunction

nnoremap <leader>sh <Cmd>call SwitchSourceHeader()<CR>

" Wired:
cnoremap <C-r> %:r<tab>
noremap <A-r> %:r<tab>
" Expands to the directory of the current filename, using ~ for $HOME,
" and using path relative to the current directory if applicable.
" `help fnamemodify()`
cnoremap <C-e> %:.:h/<tab>
cnoremap <A-e> %:.:h/<tab>

" Use escape to exit terminal mode.
tnoremap <Esc> <C-\><C-n>

" <A-CR> to insert and goto line above.
inoremap <A-CR> <Esc>O

" Go to the end of the line in insert mode.
inoremap <C-L> <C-o>A

" Copy current command line.
cnoremap <C-y> <C-f>Vy<C-c>

" Open the current file again in a new tab.
nnoremap <leader>ts <Cmd>tab split<CR>

" Edit and source init.vim shortcuts.
nnoremap <leader>ev <Cmd>tabedit $MYVIMRC<CR>
nnoremap <leader>sv <Cmd>source $MYVIMRC<CR>


" Delete a Python type hint comment on the current line. ...Apparently I used this enough to make this a mapping?
"nnoremap <leader>dt <Cmd>substitute/\s#\stype:.\+//<CR>
" I did not. But I did instead use:

" Delete a Rust-style type annotation for the current variable.
nnoremap <leader>dta m0f:xwdaW`0

" Delete a function call, leaving the arguments intact.
"nmap dsf dt(ds)
nmap dsf dt(<Plug>Dsurround)

" "Delete function application"
" Deletes a parenthesized function application in the Nix language, leaving the inner arguments intact.
" Parts:
" T( — jump to one column after (to the right) of the nearest opening parenthesis
" <Plug>Dsurround) — Delete surrounding parentheses
" daw — Delete the current WORD (to include things like dots, in case the function name is qualified).
nmap <leader>dfa T(<Plug>Dsurround)daW

" Delete a GenericWrapper<>, leaving the inner arguments intact.
" 'Delete surrounding template'
nmap dst dt<<Plug>Dsurround>

" 'Delete after comma'
nnoremap <leader>da, viwf,ld

 "Visual select to after <noun>.
"nnoremap <leader>vt

" Delete an assignment.
nnoremap da= vf=ld

" Change a member access to a Python style dict access. 'Change Member To Dict'
nmap cmtd eviwS'va'S]h"_x

" Change a Python style dict access to a member access. 'Change Dict to Member'
nmap cdtm ds'F[i.<ESC><ESC>f[ds]

" Change current word to uppercase.
inoremap <C-u> <esc>mzgUiW`za

" Comment-out the current line, and then duplicate the uncommented version below.
" 'Yank, comment, paste'
" yy to yank the current line
" <leader>cc for comment.nvim's toggle line comment
" <leader>p to paste without indenting (see above).
nmap <leader>ycp yy<leader>cc<leader>p

" Yank, then comment out, on a visual selection.
vmap <leader>Y Ygv<leader>cc

" Inverts formatoptions' "r" flag, which automatically inserts the comment leader on <CR>
" in insert mode.
function! InvertR() abort
	if &formatoptions =~# "r"
		setlocal formatoptions-=r
	else
		setlocal formatoptions+=r
	endif
endfunction

function! InvertRAndEcho() abort
	if &formatoptions =~# "r"
		echomsg "Comment continuation off"
		setlocal formatoptions-=r
	else
		echomsg "Comment continuation on"
		setlocal formatoptions+=r
	endif
endfunction

" Invert formatoptoins' "r" flag for exactly one insert mode session.
function! InsertInvertR() abort
	call InvertR()
	augroup InsertInvertR
		autocmd! InsertLeave * ++once call InvertR()
	augroup END
endfunction

" Prefix insert mode entry commands with <leader>r to invert formatoptions' "r" flag for
" that single insert mode session. We usually have formatoptions' "r" disabled by default,
" so this will typically temporarily enable it.
nnoremap <leader>ri :call InsertInvertR()<CR>i
nnoremap <leader>ro :call InsertInvertR()<CR>o
nnoremap <leader>rO :call InsertInvertR()<CR>O
nnoremap <leader>ra :call InsertInvertR()<CR>a
nnoremap <leader>rA :call InsertInvertR()<CR>A

lua << EOF
-- Returns true if this function inverted fo=r, and false if it did not.
function doc_format_options()
	local pos = vim.inspect_pos(nil, nil, nil, { syntax = false, extmarks = false, semantic_tokens = false })

	if pos == nil then
		return false
	end

	for i, capture in ipairs(pos.treesitter) do
		if capture.capture == "comment.documentation" then
			vim.cmd.echo([['setting formatoptions+=r']])
			vim.fn["InsertInvertR"]()
			return true
		end
	end

	return false
end
EOF

" Experimental: when entering insert mode while in a doc-comment, setlocal formatoptions+=r
" for that insert session.
augroup DocFormatOptions
	autocmd! InsertEnter * lua doc_format_options()
augroup END

"nnoremap <expr> o (v:lua.doc_format_options() ? "i\<esc>o" : "o") " Need to decide if I want this one
inoremap <expr> <CR> (v:lua.doc_format_options() ? "\<CR>" : "\<CR>")


" Okay okay wait, let's try a more flexible version of the "I only want fo+=r for a sec"
let g:insert_r_inverted = v:false
function! CheckInvertedR() abort
	if g:insert_r_inverted == v:true
		setlocal formatoptions-=r
		echomsg "Comment continuation off"
	endif
endfunction
augroup CheckInvertedR
	autocmd! InsertLeave * call CheckInvertedR()
augroup END
lua << EOF
function invert_r_temporarily()
	local current_r = vim.opt_local.formatoptions:get().r
	-- Will be either nil or false, the two falsey values.
	if not current_r then
		vim.cmd.echomsg [["Comment continuation on"]]
		vim.opt_local.formatoptions:append { r = true }
	else
		vim.cmd.echomsg [["Comment continuation off"]]
		vim.opt_local.formatoptions:append { r = false }
	end
	vim.g.insert_r_inverted = true
end

-- <A-d> for "_D_oc-comment... or something"
vim.keymap.set('i', '<A-d>', invert_r_temporarily)
EOF

command! -range=% Interleave execute 'keeppatterns' (<line2>-<line1>+1)/2+<line1> ',' <line2> 'g/^/<line1> move -1'

function! Redir(command)
	enew
	put =execute(a:command)
endfunction

command! -nargs=+ -complete=command Redir call Redir(<Q-Args>)

function! Notify(command) abort
	call v:lua.vim.notify(execute(a:command))
endfunction

" Run a command and show its output as a notification.
command! -nargs=+ -complete=command Notify call Notify(<Q-Args>)

""" Implementation for :Bload
function! Bload(...) abort

	" Build the total list of files.
	let l:files = []
	for l:arg in a:000
		let l:expanded = expand(l:arg, "", v:true)
		call extend(l:files, l:expanded)
	endfor

	" Execute :badd for each file.
	for l:file in l:files
		execute "badd " . l:file
	endfor

	" And give us a short summary of what happened.
	echomsg "Added " . len(l:files) . " buffers."

endfunction
""" Load the provided filenames as buffers without opening windows for them.
" Arguments are passed to `expand()`, so the same syntax as commands like `:edit` is supported
" for each argument.
command! -nargs=+ -complete=file Bload call Bload(<f-args>)

" Like `*` (searches for the current word), but doesn't actually perform the search operation,
" instead only setting the search pattern *register* (`/`), and re-setting 'hlsearch'.
" In other words, higlight the current word and all occurences of it, and make the "next"
" and "previous" search commands (`n` and `N`) also use the current word.
nnoremap <leader>* <Cmd>let @/ = '\<' . expand("<cword>") . '\>' \| set hlsearch<CR>

lua <<EOF
local function get_vim_errstr(lua_errstr)
	-- lua_errstr should look something like `[string ":lua"]:10: Vim:E999: foomsg`
	-- Vim displays errors like `E999: foomsg`. So let's get that part.
	local to_strip = string.find(lua_errstr, "Vim:") + #"Vim:"
	return string.sub(lua_errstr, to_strip)
end
-- Make jumping to search matches use a larger 'scrolloff' value.
vim.keymap.set("n", "n",
	function()
		local prev_scrolloff = vim.wo.scrolloff
		vim.wo.scrolloff = 15
		local status, err = pcall(function() vim.cmd.normal { args = { "n" }, bang = true } end)
		if status == false then
			vim.api.nvim_err_writeln(get_vim_errstr(err))
		end
		vim.wo.scrolloff = prev_scrolloff
	end,
	{ desc = "Same as normal `n`, but with `scrolloff=15`" }
)
vim.keymap.set("n", "N",
	function()
		local prev_scrolloff = vim.wo.scrolloff
		vim.wo.scrolloff = 15
		local status, err = pcall(function() vim.cmd.normal { args = { "N" }, bang = true } end)
		if status == false then
			vim.api.nvim_err_writeln(get_vim_errstr(err))
		end
		vim.wo.scrolloff = prev_scrolloff
	end,
	{ desc = "Same as normal `N`, but with `scrolloff=15`" }
)
EOF


lua << EOF
use 'tpope/vim-surround'
use 'justinmk/vim-sneak'
use {
	'numToStr/Comment.nvim',
	opts = {
		-- Don't add a space for commented-out lines.
		padding = false,
		toggler = {
			line = "<leader>cc",
			block = "<leader>bc",
		},
		opleader = {
			line = "<leader>cc",
			block = "<leader>bc",
		},
	},
	keys = {
		{ "<leader>cc" },
		{ "<leader>bc" },
		{ "<leader>cc", mode = "v" },
		{ "<leader>bc", mode = "v" },
	},
}
use 'vim-scripts/vis' -- Block selection range commands.
use 'wsdjeg/vim-fetch'
use 'famiu/bufdelete.nvim' -- :Bdelete without messing up window layout.
use 'tpope/vim-repeat'
EOF
