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
		let self.line_parser_ = bufexport#line_parser#new(self.listchars_)
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
			let tokens = self.line_parser_.parse(lnum)

			if self.needs_number_
				let lnum_text = s:emulate_lnum(lnum, self.max_lnum_)
				call insert(tokens, bufexport#token#new(lnum_text, 'LineNr'), 0)
			endif

			if self.needs_eol_
				call add(tokens, bufexport#token#new(self.listchars_.eol, 'NonText'))
			endif

			call add(result, tokens)

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
	let max_len = strlen(string(a:max_lnum))
	let pad = min([max_len - strlen(string(a:lnum)), 3])
	return repeat(' ', pad) . string(a:lnum) . ' '
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
