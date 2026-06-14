" dosini is close enough
augroup FtDetectNetworkManager
	autocmd! BufNew,BufRead /*/NetworkManager/*.conf,NetworkManager.conf,*.nmconnection setlocal filetype=dosini
augroup END
