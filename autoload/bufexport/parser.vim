" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! bufexport#parser#new()
	let parser = {}

	function! parser.prepare_() dict
		" TODO: Save current settings

		set conceallevel=1
		normal! zR

		let self.listchars_ = s:parse_listchars()
		let self.needs_number_ = &number
		let self.needs_eol_ = (strlen(get(self.listchars_, 'eol', '')) > 0)
	endfunction

	function! parser.restore_() dict
		" TODO: Implement
	endfunction

	function! parser.parse() dict
		let result = []

		call self.prepare_()

		let self.max_lnum_ = line('$')
		let lnum = 1
		while lnum <= self.max_lnum_
			let tokens = self.parse_line(lnum)

			if self.needs_number_
				let lnum_text = s:emulate_lnum(lnum, self.max_lnum_)
				call insert(tokens, s:token(lnum_text, 'LineNr'), 0)
			endif

			if self.needs_eol_
				call add(tokens, s:token(self.listchars_.eol, 'NonText'))
			endif

			call add(result, tokens)

			let lnum += 1
		endwhile

		call self.restore_()

		return result
	endfunction

	function! parser.parse_line(lnum) dict
		if strlen(getline(a:lnum)) == 0
			return []
		endif

		let result = []

		let tab = get(self.listchars_, 'tab', '')

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

	return parser
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


function! s:syn_name(lnum, col)
	return synIDattr(synID(a:lnum, a:col, 'gui'), 'name')
endfunction


function! s:concealed(lnum, col)
	return synconcealed(a:lnum, a:col)[0]
endfunction


function! s:token(text, name)
	return {
				\ 'text': a:text,
				\ 'name': a:name
				\ }
endfunction


function! s:emulate_lnum(lnum, max_lnum)
	let max_len = strlen(string(a:max_lnum))
	let pad = min([max_len - strlen(string(a:lnum)), 3])
	return repeat(' ', pad) . string(a:lnum) . ' '
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


let &cpo = s:save_cpo
unlet s:save_cpo
