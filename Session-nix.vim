let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/.config
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +1 flake.nix
badd +16 nixos/common.nix
badd +1 nixos/dev.nix
badd +50 nixos/linux.nix
badd +53 nixos/linux-gui.nix
badd +1 nixos/pkgs/xonsh.nix
badd +48 nixos/pkgs/xonsh/flake.nix
badd +0 nixos/pkgs/nix-helpers.nix
argglobal
%argdel
$argadd flake.nix
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit flake.nix
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=5
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 1 - ((0 * winheight(0) + 39) / 79)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 0
tabnext
edit nixos/common.nix
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 36 + 41) / 82)
exe 'vert 1resize ' . ((&columns * 175 + 174) / 349)
exe '2resize ' . ((&lines * 36 + 41) / 82)
exe 'vert 2resize ' . ((&columns * 173 + 174) / 349)
argglobal
balt nixos/dev.nix
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=5
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 16 - ((11 * winheight(0) + 18) / 36)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 16
normal! 0
wincmd w
argglobal
if bufexists(fnamemodify("nixos/dev.nix", ":p")) | buffer nixos/dev.nix | else | edit nixos/dev.nix | endif
if &buftype ==# 'terminal'
  silent file nixos/dev.nix
endif
balt nixos/common.nix
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=5
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 13 - ((9 * winheight(0) + 18) / 36)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 13
normal! 09|
wincmd w
exe '1resize ' . ((&lines * 36 + 41) / 82)
exe 'vert 1resize ' . ((&columns * 175 + 174) / 349)
exe '2resize ' . ((&lines * 36 + 41) / 82)
exe 'vert 2resize ' . ((&columns * 173 + 174) / 349)
tabnext
edit nixos/linux.nix
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 175 + 174) / 349)
exe 'vert 2resize ' . ((&columns * 173 + 174) / 349)
argglobal
balt nixos/linux-gui.nix
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=5
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 40 - ((39 * winheight(0) + 39) / 79)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 40
normal! 0
wincmd w
argglobal
if bufexists(fnamemodify("nixos/linux-gui.nix", ":p")) | buffer nixos/linux-gui.nix | else | edit nixos/linux-gui.nix | endif
if &buftype ==# 'terminal'
  silent file nixos/linux-gui.nix
endif
balt nixos/linux.nix
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=5
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 53 - ((2 * winheight(0) + 39) / 79)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 53
normal! 011|
wincmd w
exe 'vert 1resize ' . ((&columns * 175 + 174) / 349)
exe 'vert 2resize ' . ((&columns * 173 + 174) / 349)
tabnext
edit nixos/pkgs/xonsh/flake.nix
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 174 + 174) / 349)
exe 'vert 2resize ' . ((&columns * 174 + 174) / 349)
argglobal
balt nixos/pkgs/nix-helpers.nix
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=5
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 48 - ((41 * winheight(0) + 39) / 79)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 48
normal! 015|
wincmd w
argglobal
if bufexists(fnamemodify("nixos/pkgs/nix-helpers.nix", ":p")) | buffer nixos/pkgs/nix-helpers.nix | else | edit nixos/pkgs/nix-helpers.nix | endif
if &buftype ==# 'terminal'
  silent file nixos/pkgs/nix-helpers.nix
endif
balt nixos/pkgs/xonsh/flake.nix
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=5
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 20 - ((19 * winheight(0) + 39) / 79)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 20
normal! 04|
wincmd w
exe 'vert 1resize ' . ((&columns * 174 + 174) / 349)
exe 'vert 2resize ' . ((&columns * 174 + 174) / 349)
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
