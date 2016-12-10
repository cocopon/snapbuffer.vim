" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:special_chars = [
			\ 	['&', '\&amp;'],
			\ 	['>', '\&gt;'],
			\ 	['<', '\&lt;'],
			\ 	['"', '\&quot;'],
			\ ]


function! snapbuffer#exporter#html#export(data) abort
	let result = ''

	for token in a:data
		let line = s:css_token(token)
		let result .= line
	endfor

	return result
endfunction


function! snapbuffer#exporter#html#finish() abort
	set ft=html
endfunction


function! s:css_token(token) abort
	let result = ''

	if a:token.display ==# 'block'
		let result .= '<div'
	elseif a:token.display ==# 'inline'
		let result .= '<span'
	endif

	if !empty(a:token.name)
		let result .= printf(' class="%s"', a:token.name)
	endif

	let result .= '>'

	if has_key(a:token, 'text')
		let result .= s:escape(a:token.text)
	elseif has_key(a:token, 'children')
		for child in a:token.children
			let result .= s:css_token(child)
		endfor
	endif

	if a:token.display ==# 'block'
		let result .= '</div>'
	elseif a:token.display ==# 'inline'
		let result .= '</span>'
	endif

	return result
endfunction


function! s:escape(text) abort
	let text = a:text

	for pair in s:special_chars
		let text = substitute(text, pair[0], pair[1], 'g')
	endfor

	return text
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
