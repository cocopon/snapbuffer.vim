" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! snapbuffer#export(...)
  let parser = snapbuffer#parser#new()
	let data = parser.parse()

	let exporter = 'html'
	if a:0 >= 1
		let exporter = a:1
	end

	let func = printf('snapbuffer#exporter#%s#export', exporter)
	try
		let text = call(func, [data])
	catch /:E117:/
		" E117: Unknown function
		echoerr printf('Exporter not found: %s', exporter)
		return
	endtry

	new
	call append(0, text)
	set nomodified
	set ft=html
	normal! gg
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
