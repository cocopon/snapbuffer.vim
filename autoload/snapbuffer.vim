" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! snapbuffer#export(...)
	let env = snapbuffer#env#new()
  let parser = snapbuffer#parser#new(env)

	let data = parser.parse()

	try
		let exporter = 'html'
		if a:0 >= 1
			let exporter = a:1
		end
		let export_func = printf('snapbuffer#exporter#%s#export', exporter)
		let text = call(export_func, [data])
	catch /:E117:/
		" E117: Unknown function
		echoerr printf('Exporter not found: %s', exporter)
		return
	endtry

	new
	call append(0, text)
	set nomodified
	normal! gg
	let finish_func = printf('snapbuffer#exporter#%s#finish', exporter)
	call function(finish_func)()
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
