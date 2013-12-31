" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:methods = [
			\ 	'parse',
			\ 	'prepare_for_next_syntax_',
			\ 	'publish_token_',
			\ 	'reset_',
			\ 	'syn_name_',
			\ ]


function! snapbuffer#line_parser#new(env)
	let parser = {}
	let parser.env_ = a:env
	let parser.cursor_visible_ = get(g:, 'snapbuffer_cursor_visible', 0)

	call snapbuffer#util#setup_methods(
				\ parser,
				\ 'snapbuffer#line_parser',
				\ s:methods)

	return parser
endfunction


function! snapbuffer#line_parser#syn_name_(lnum, col) dict
	if self.cursor_visible_
		if self.env_.cursor_lnum == a:lnum
					\ && self.env_.cursor_col == a:col
			return 'Cursor'
		endif
	endif

	return synIDattr(synID(a:lnum, a:col, 'gui'), 'name')
endfunction


function! snapbuffer#line_parser#reset_(lnum) dict
	let self.result_ = []
	let self.token_text_ = ''
	let self.cur_syn_ = self.syn_name_(a:lnum, 1)

	" Move cursor to beginning of the target line
	execute printf('normal! %dG', a:lnum)
	normal! 0
endfunction


function! snapbuffer#line_parser#publish_token_() dict
	if strlen(self.token_text_) == 0
		return
	endif

	let token = snapbuffer#token#inline(self.token_text_, self.cur_syn_)
	call add(self.result_, token)
endfunction


function! snapbuffer#line_parser#prepare_for_next_syntax_(syntax) dict
	let self.cur_syn_ = a:syntax
	let self.token_text_ = ''
endfunction


function! snapbuffer#line_parser#parse(lnum) dict
	if strlen(getline(a:lnum)) == 0
		return []
	endif

	call self.reset_(a:lnum)
	let tab = self.env_.listchar_tab
	let prev_text_width = 0
	let col = 1

	while 1
		" Get a character under cursor
		normal! vy
		let ch = getreg('"')

		" Check a syntax boundary
		if ch ==# "\t"
			let syn = "SpecialKey"
		else
			let syn = self.syn_name_(a:lnum, col)
		endif

		if self.cur_syn_ != syn
			call self.publish_token_()
			call self.prepare_for_next_syntax_(syn)
		endif 

		" Append character to the next token
		let text_width = strdisplaywidth(self.token_text_ . ch)
		if ch ==# "\t"
			let tab_width = text_width - prev_text_width
			let self.token_text_ .= s:emulate_tab(tab_width, tab)
		else
			let self.token_text_ .= ch
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

	call self.publish_token_()

	return self.result_
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


function! s:concealed(lnum, col)
	return synconcealed(a:lnum, a:col)[0]
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
