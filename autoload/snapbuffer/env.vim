" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! snapbuffer#env#new() abort
	let env = {}

	" cursor
	let env.cursor_lnum = line('.')
	let env.cursor_col = col('.')
	" listchars
	let env.listchars = s:parse_listchars()
	let env.listchar_eol = get(env.listchars, 'eol', '')
	let env.listchar_tab = get(env.listchars, 'tab', '')
	" options
	let env.number = &number
	let env.cursorline = &cursorline

	return env
endfunction


function! s:parse_listchars() abort
	let result = {}

	let listchars = split(&listchars, ',')
	for listchar in listchars
		let comps = split(listchar, ':')
		let result[comps[0]] = comps[1]
	endfor

	return result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
