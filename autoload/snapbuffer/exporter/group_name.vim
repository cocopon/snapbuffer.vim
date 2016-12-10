" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! snapbuffer#exporter#group_name#export(data) abort
	let result = {'Normal': 1}

	for tokens in a:data
		for token in tokens
			if empty(token.name)
				continue
			endif

			let result[token.name] = 1
		endfor
	endfor

	return keys(result)
endfunction


function! snapbuffer#exporter#group_name#finish() abort
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
