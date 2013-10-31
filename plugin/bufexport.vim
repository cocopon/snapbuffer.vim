" Author:  cocopon <cocopon@me.com>
" License: MIT License


if exists('g:loaded_bufexport') && get(g:, 'bufexport_debug', 0)
	finish
end
let g:loaded_bufexport = 1


let s:save_cpo = &cpo
set cpo&vim


command! -nargs=* BufExport call bufexport#export(<f-args>)


let &cpo = s:save_cpo
unlet s:save_cpo
