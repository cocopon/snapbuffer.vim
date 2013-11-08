" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! s:prepare()
	set conceallevel=1
	normal! zR
	let s:listchars = s:parse_listchars()
endfunction


function! bufexport#parser#parse_current_buffer()
	let result = []

	call s:prepare()

	let needs_number = &number
	let needs_eol = (strlen(get(s:listchars, 'eol', '')) > 0)

	let s:max_lnum = line('$')
	let lnum = 1
	while lnum <= s:max_lnum
		let tokens = s:parse_line(lnum)

		" TODO: Replace \t with listchars:tab

		if needs_number
			call insert(tokens, s:lnum_token(lnum), 0)
		endif

		if needs_eol
			call add(tokens, s:token(s:listchars.eol, 'NonText'))
		endif

		call add(result, tokens)

		let lnum += 1
	endwhile

	return result
endfunction

function! s:parse_listchars()
	let result = {}

	let listchars = split(&listchars, ',')
	for listchar in listchars
		let comps = split(listchar, ':')
		let result[comps[0]] = comps[1]
	endfor

	return result
endfunction

function! s:parse_line(lnum)
	if strlen(getline(a:lnum)) == 0
		return []
	endif

	let result = []

	let tab = get(s:listchars, 'tab', '')

	" Move cursor to beginning of the target line
	execute printf('normal! %dG', a:lnum)
	normal! 0

	let col = 1
	let prev_text_width = 0
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

		let text_width = strdisplaywidth(text . ch)
		if ch ==# "\t"
			let tab_width = text_width - prev_text_width
			" TODO: Apply hi-SpecialKey
			let text .= s:emulate_tab(tab_width, tab)
		else
			let text .= ch
		endif
		let prev_text_width = text_width

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

	return result
endfunction

function! s:syn_name(lnum, col)
	return synIDattr(synID(a:lnum, a:col, 'gui'), 'name')
endfunction

function! s:concealed(lnum, col)
	return synconcealed(a:lnum, a:col)[0]
endfunction

function! s:emulate_tab(width, tab)
	let first = ' '
	let second = ' '

	let matches = matchlist(a:tab, '^\(.\)\(.\)$')
	if !empty(matches)
		let first = matches[1]
		let second = matches[2]
	endif

	return first . repeat(second, a:width - 1)
endfunction

function! s:lnum_token(lnum)
	let max_len = strlen(string(s:max_lnum))
	let pad = min([max_len - strlen(string(a:lnum)), 3])
	let text = repeat(' ', pad) . string(a:lnum) . ' '

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
