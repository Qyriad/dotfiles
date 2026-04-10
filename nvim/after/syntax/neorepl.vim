imap <buffer> <Up> <Plug>(neorepl-hist-prev)
imap <buffer> <Down> <Plug>(neorepl-hist-next)
imap <buffer> <C-L> <Cmd>lua require('neorepl.bufs').get():clear()<CR>
