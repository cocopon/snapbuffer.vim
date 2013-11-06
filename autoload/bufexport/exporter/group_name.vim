" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! bufexport#exporter#group_name#export(data)
	let result = {}

	for tokens in a:data
		for token in tokens
			if strlen(token.name) == 0
				continue
			endif

			let result[token.name] = 1
		endfor
	endfor

	return keys(result)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
