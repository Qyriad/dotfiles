function copyonwrite#enable() abort
	augroup CopyOnWrite
		" Yank the entire file into "+
		autocmd! BufWritePost <buffer> silent %yank +
	augroup END
endfunction

function copyonwrite#disable() abort
	augroup CopyOnWrite
		autocmd!
	augroup END
endfunction
