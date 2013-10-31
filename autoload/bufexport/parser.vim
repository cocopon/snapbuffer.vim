" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! bufexport#parser#parse_current_buffer()
	let result = []

	normal! zR

	let s:max_lnum = line('$')
	let lnum = 1
	while lnum <= s:max_lnum
		call add(result, s:parse_line(lnum))
		let lnum += 1
	endwhile

	return result
endfunction

function! s:parse_line(lnum)
	let result = []

	" Move cursor to beginning of the target line
	execute printf('normal! %dG', a:lnum)
	normal! 0

	let max_col = col('$') - 1
	let col = 1
	let text = ''
	let cur_syn = s:syn_name(a:lnum, 1)

	while 1
		let syn = s:syn_name(a:lnum, col)
		if cur_syn != syn
			call add(result, s:token(text, cur_syn))
			let cur_syn = syn
			let text = ''
		endif 

		" Append a character under cursor
		normal! vy
		let ch = getreg('"')
		let text .= ch

		" Move cursor to the next character
		normal! l

		let prev_col = col
		let col = col('.')
		if col == prev_col
			break
		endif
	endwhile

	if strlen(text) > 0
		call add(result, s:token(text, cur_syn))
	endif

	" Insert line number
	if &number
		call insert(result, s:generate_number(a:lnum), 0)
		call insert(result, s:token(' ', 'Normal'), 1)
	endif

	return result
endfunction

function! s:syn_name(lnum, col)
	return synIDattr(synID(a:lnum, a:col, 'gui'), 'name')
endfunction

function! s:generate_number(lnum)
	let max_len = strlen(string(s:max_lnum))
	let pad = max_len - strlen(string(a:lnum))
	let text = repeat(' ', pad) . string(a:lnum)

	return s:token(text, 'LineNr')
endfunction

function! s:token(text, name)
	return {
				\ 'text': a:text,
				\ 'name': a:name
				\ }
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
