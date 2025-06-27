" Don't automatically insert the comment leader on <CR> or o
setlocal formatoptions-=ro

"if exists("*nvim_treesitter#foldexpr")
"	setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()
"endif
setlocal foldmethod=syntax
setlocal foldtext=
