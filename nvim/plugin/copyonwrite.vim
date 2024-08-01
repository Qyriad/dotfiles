if exists('g:loaded_copyonwrite')
	finish
endif
let g:loaded_copyonwrite = v:true

command! CopyOnWrite call copyonwrite#enable()
command! NoCopyOnWrite call copyonwrite#disable()
