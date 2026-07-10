" By default, wrap :Man pages to 120 characters.
" Set $MANWIDTH=0 to disable wrap
if getenv("MANWIDTH") == v:null
	let $MANWIDTH = 120
endif
if getenv("MANWIDTH") != 0
	let g:man_hardwrap = 1
endif
