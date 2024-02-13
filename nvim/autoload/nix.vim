let s:skipped_syn_ids = [hlID('nixComment'), hlID('nixString'), hlID('nixStringSpecial')]

function! nix#syn_should_ignore() abort
	return s:skipped_syn_ids->count(synID(line('.'), col('.'), 0)) > 0
endfunction
