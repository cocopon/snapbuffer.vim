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


function! snapbuffer#exporter#html#export(data)
	let result = []

	for tokens in a:data
		let line = ''

		for token in tokens
			let line .= s:exporter_css_token(token)
		endfor

		call add(result, line)
	endfor

	return result
endfunction

function! s:exporter_css_token(token)
	let css = a:token.name
	let text = s:escape(a:token.text)
	return printf('<span class="%s">%s</span>', css, text)
endfunction

function! s:escape(text)
	let text = a:text

	for pair in s:special_chars
		let text = substitute(text, pair[0], pair[1], 'g')
	endfor

	return text
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
