" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! bufexport#token#new(text, name)
	return {
				\ 'text': a:text,
				\ 'name': a:name
				\ }
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
