augroup cpp_headers
	autocmd!
	autocmd BufRead,BufNewFile *.h set filetype=cpp.doxygen shiftwidth=2 expandtab
	autocmd BufRead,BufNewFile *.cpp set filetype=cpp.doxygen shiftwidth=2 expandtab
	autocmd Filetype arduino set shiftwidth=2 expandtab
augroup END
