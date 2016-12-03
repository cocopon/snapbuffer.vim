" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:V = vital#snapbuffer#new()
call s:V.load('Web.JSON')


function! snapbuffer#exporter#json#export(data)
	let result = []

	for token in a:data
		call add(result, s:export_token(token))
	endfor

	return s:V.Web.JSON.encode(result)
endfunction


function! snapbuffer#exporter#json#finish()
	set ft=json
endfunction


function! s:export_token(token)
	let result = {}

	let result['display'] = a:token.display

	if !empty(a:token.name)
		let result['class'] = a:token.name
	endif

	if has_key(a:token, 'text')
		let result['text'] = a:token.text
	elseif has_key(a:token, 'children')
		let children = []
		for child in a:token.children
			call add(children, s:export_token(child))
		endfor
		let result['children'] = children
	endif

	return result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
