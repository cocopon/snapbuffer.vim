" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! snapbuffer#token#inline(text, name) abort
	return {
				\ 	'display': 'inline',
				\ 	'text': a:text,
				\ 	'name': a:name,
				\ }
endfunction


function! snapbuffer#token#block(name, children) abort
	return {
				\ 	'display': 'block',
				\ 	'children': a:children,
				\ 	'name': a:name,
				\ }
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
