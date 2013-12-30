" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! snapbuffer#parser#new()
	let parser = {}

	function! parser.prepare_() dict
		" TODO: Save current settings
		set conceallevel=1

		let self.listchars_ = s:parse_listchars()
		let self.needs_number_ = &number
		let self.needs_eol_ = (strlen(get(self.listchars_, 'eol', '')) > 0)
		let self.needs_cursorline_ = &cursorline
		let self.line_parser_ = snapbuffer#line_parser#new(self.listchars_)
		let self.cursor_lnum_ = get(g:, 'snapbuffer_cursor_lnum', 0)
	endfunction

	function! parser.restore_() dict
		" TODO: Implement
	endfunction

	function! parser.parse() dict
		let max_col = winwidth(0)
		let result = []

		call self.prepare_()

		let self.max_lnum_ = line('$')
		let lnum = 1
		while lnum <= self.max_lnum_
			let tokens = []
			let highlight_line = (self.needs_cursorline_ && lnum == self.cursor_lnum_)

			if self.needs_number_
				let lnum_text = s:emulate_lnum(lnum, self.max_lnum_)
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

				if self.needs_eol_
					call add(tokens, snapbuffer#token#inline(self.listchars_.eol, 'NonText'))
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
