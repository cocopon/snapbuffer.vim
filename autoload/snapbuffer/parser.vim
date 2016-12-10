" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:methods = [
			\ 	'parse',
			\ 	'parse_empty_line_',
			\ 	'parse_line_',
			\ 	'prepare_',
			\ 	'restore_',
			\ ]


function! snapbuffer#parser#new(env) abort
	let parser = {}
	let parser.env_ = a:env
	let parser.cursor_visible_ = get(g:, 'snapbuffer_cursor_visible', 0)

	call snapbuffer#util#setup_methods(
				\ parser,
				\ 'snapbuffer#parser',
				\ s:methods)

	return parser
endfunction


function! snapbuffer#parser#prepare_() abort dict
	let self.states_ = {
				\ 	'pos': getpos('.')
				\ }
	let self.line_parser_ = snapbuffer#line_parser#new(self.env_)
endfunction


function! snapbuffer#parser#restore_() abort dict
	call setpos('.', self.states_.pos)
endfunction


function! snapbuffer#parser#parse_line_(tokens, lnum) abort dict
	call extend(a:tokens, self.line_parser_.parse(a:lnum))

	if !empty(self.env_.listchar_eol)
		call add(a:tokens, snapbuffer#token#inline(self.env_.listchar_eol, 'NonText'))
	endif
endfunction


function! snapbuffer#parser#parse_empty_line_(tokens, lnum) abort dict
	let listchar_eol = self.env_.listchar_eol

	if self.cursor_visible_ && self.env_.cursor_lnum == a:lnum
		let cursor_token = snapbuffer#token#inline(
					\ !empty(listchar_eol) ? listchar_eol : ' ',
					\ 'Cursor')
		call add(a:tokens, cursor_token)
	else
		if !empty(listchar_eol)
			call add(a:tokens, snapbuffer#token#inline(listchar_eol, 'NonText'))
		endif
	endif
endfunction


function! snapbuffer#parser#parse() abort dict
	let max_col = winwidth(0)
	let result = []

	call self.prepare_()

	let max_lnum = line('$')
	let lnum = 1
	while lnum <= max_lnum
		let tokens = []
		let highlight_line = self.cursor_visible_
					\ && self.env_.cursorline
					\ && lnum == self.env_.cursor_lnum

		if self.env_.number
			let lnum_text = s:emulate_lnum(lnum, max_lnum)
			let token = snapbuffer#token#inline(
						\ lnum_text,
						\ (highlight_line ? 'CursorLineNr' : 'LineNr'))
			call insert(tokens, token, 0)
		endif

		if foldclosed(lnum) > 0
			let fold_text = s:emulate_folding(lnum, max_col)
			call add(tokens, snapbuffer#token#inline(fold_text, 'Folded'))
			let lnum = foldclosedend(lnum)
		else
			if !empty(getline(lnum))
				call self.parse_line_(tokens, lnum)
			else
				call self.parse_empty_line_(tokens, lnum)
			endif
		endif

		let line_token = snapbuffer#token#block(
					\ (highlight_line ? 'CursorLine' : ''),
					\ tokens)
		call add(result, line_token)

		let lnum += 1
	endwhile

	call self.restore_()

	return result
endfunction


function! s:emulate_lnum(lnum, max_lnum) abort
	let max_len = max([strlen(string(a:max_lnum)), 3])
	let pad = max_len - strlen(string(a:lnum))
	return repeat(' ', pad) . string(a:lnum) . ' '
endfunction


function! s:emulate_folding(lnum, max_col) abort
	let fold_text = foldtextresult(a:lnum)
	let separator = repeat('-', a:max_col - strdisplaywidth(fold_text))
	return fold_text . separator
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
