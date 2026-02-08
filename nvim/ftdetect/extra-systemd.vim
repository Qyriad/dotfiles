" Idk why these don't get detected as systemd but they will now.
augroup ExtraSystemdDetect
	autocmd! BufNew,BufRead /*/systemd/*.conf setlocal filetype=systemd
augroup END
