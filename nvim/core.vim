"
" Core Neovim configuration. I don't want to use Neovim without most of these.
" You can pry this file from my cold dead hands.
"

scriptencoding utf-8

syntax on
filetype plugin indent on

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
set textwidth=120 " Wrap text at 120 chracters by default.
set wildmenu " Tab-complete command menu.
set wildmode=longest:full,full " Most bash-like way.
set wildignorecase " Ignore case when completing.
set timeoutlen=1000 ttimeoutlen=10 " Remove <Esc> leaving insert mode delay in Tmux.
set splitright " Make :vsplit put the new window on the right.
set splitbelow " Make :split put the new window on the bottom.
set foldlevel=5 " Don't fold almost anything by default.
set hidden " Allow for hidden, modified but not written buffers.
set bufhidden=hide " Hide buffers instead of deleting or unloading them.
set ignorecase
set smartcase
set gdefault " Substitute all matches in a line by default.
set cindent " A good basis/default for many languages, though this is usually overridden by the filetype plugin.
set cinoptions=l1,j1 " Indent case blocks correct, and indent Java anonymous classes correctly.
" Autowrap comments using textwidth, inserting the comment leader,
" and remove the comment leader when joining lines when it makes sense.
set formatoptions=cj
" Don't display . on folds.
set fillchars=fold:\ 
set diffopt=algorithm:patience
set fsync " Syncs the filesystem after :write.


set updatetime=1000 "Lets languageservers update faster, and shortens the time for CursorHold.
set noshowmode " We're using lightline, so showing the mode in the command line is redundant.


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

	if line("'\"") <= line("$")
		normal! g`"
		return 1
	endif
endfunction

augroup restore_last_position
	autocmd! BufWinEnter * call Restore_last_position()
augroup END


" Turn off hlsearch when entering insert mode.
augroup insert_nohlsearch
	autocmd! InsertEnter * nohlsearch
augroup END


""" Filetype overrides.

augroup c_ft_headers
	autocmd!
	autocmd BufRead,BufNewFile *.h set filetype=c.doxygen
	autocmd FileType c set filetype=c.doxygen
augroup END

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


" Set these for zsh edit-command-line.
function! Zshedit()
	set nomagic inccommand=nosplit
	cunabbrev wq
endfunction

augroup zsh_set
	autocmd! BufRead /tmp/zsh* call Zshedit()
augroup END


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

" Switch buffer.
nnoremap <leader>sb <Cmd>Bs<CR>

" Use escape to exit terminal mode.
tnoremap <Esc> <C-\><C-n>

" \$ for last charactrer.
"nnoremap <leader>$ $h
"vnoremap <leader>$ $h

" Actually, fuck it. $ for last character.
nnoremap $ $h
vnoremap $ $h

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
nnoremap <leader>sv <Cmd>tabedit $MYVIMRC<CR>


" Delete a Python type hint comment on the current line. ...Apparently I used this enough to make this a mapping?
"nnoremap <leader>dt <Cmd>substitute/\s#\stype:.\+//<CR>
" I did not. But I did instead use:

" Delete a Rust-style type annotation for the current variable.
nnoremap <leader>dta m0f:xwdaW`0

" Delete a function call, leaving the arguments intact.
"nmap dsf dt(ds)
nmap dsf dt(<Plug>Dsurround)

" Delete a GenericWrapper<>, leaving the inner arguments intact.
"nmap dst dt<ds>
nmap dst dt<<Plug>Dsurround>

" Delete an assignment.
nnoremap da= vf=ld

" Change a member access to a Python style dict access. 'Change Member To Dict'
nmap cmtd eviwS'va'S]h"_x

" Change a Python style dict access to a member access. 'Change Dict to Member'
nmap cdtm ds'F[i.<ESC><ESC>f[ds]

command! -range=% Interleave execute 'keeppatterns' (<line2>-<line1>+1)/2+<line1> ',' <line2> 'g/^/<line1> move -1'

function! Redir(command)
	enew
	put =execute(a:command)
endfunction

command! -nargs=+ -complete=command Redir call Redir(<Q-Args>)


lua << EOF
vim.g.plugins = vim.list_extend(vim.g.plugins, {
	'tpope/vim-surround',
	'scrooloose/nerdcommenter',
	'vim-scripts/vis', -- Block selection range commands.
	'editorconfig/editorconfig-vim',
})
EOF
