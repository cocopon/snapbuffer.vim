" Author:  cocopon <cocopon@me.com>
" License: MIT License


if exists('g:loaded_snapbuffer') && get(g:, 'snapbuffer_debug', 0)
	finish
end
let g:loaded_snapbuffer = 1


let s:save_cpo = &cpo
set cpo&vim


command! -nargs=* SnapBuffer call snapbuffer#export(<f-args>)


let &cpo = s:save_cpo
unlet s:save_cpo
