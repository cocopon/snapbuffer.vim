" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:methods = [
			\ 	'parse',
			\ 	'prepare_',
			\ 	'restore_',
			\ ]


function! snapbuffer#parser#new(env)
	let parser = {}
	let parser.env_ = a:env
	let parser.cursor_visible_ = get(g:, 'snapbuffer_cursor_visible', 0)

	call snapbuffer#util#setup_methods(
				\ parser,
				\ 'snapbuffer#parser',
				\ s:methods)

	return parser
endfunction


function! snapbuffer#parser#prepare_() dict
	let self.states_ = {
				\ 	'pos': getpos('.')
				\ }
	let self.line_parser_ = snapbuffer#line_parser#new(self.env_)
endfunction


function! snapbuffer#parser#restore_() dict
	call setpos('.', self.states_.pos)
endfunction


function! snapbuffer#parser#parse() dict
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
			call extend(tokens, self.line_parser_.parse(lnum))

			if !empty(self.env_.listchar_eol)
				call add(tokens, snapbuffer#token#inline(self.env_.listchar_eol, 'NonText'))
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


function! s:emulate_lnum(lnum, max_lnum)
	let max_len = max([strlen(string(a:max_lnum)), 3])
	let pad = max_len - strlen(string(a:lnum))
	return repeat(' ', pad) . string(a:lnum) . ' '
endfunction


function! s:emulate_folding(lnum, max_col)
	let fold_text = foldtextresult(a:lnum)
	let separator = repeat('-', a:max_col - strdisplaywidth(fold_text))
	return fold_text . separator
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
