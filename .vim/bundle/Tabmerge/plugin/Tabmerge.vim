" Tabmerge -- Merge the windows in a tab with the current tab.
"
" Copyright July 17, 2007 Christian J. Robinson <infynity@onewest.net>
"
" Distributed under the terms of the Vim license.  See ":help license".

" Usage:
"
" :Tabmerge [tab number] [top|bottom|left|right]
"
" The tab number can be "$" for the last tab.  If the tab number isn't
" specified the tab to the right of the current tab is merged.  If there
" is no right tab, the left tab is merged.
"
" The location specifies where in the current tab to merge the windows.
" Defaults to "top".
"
" Limitations:
"
" Vertical windows are merged as horizontal splits.  Doing otherwise would be
" nearly impossible.

if v:version < 700
	echoerr "Tabmerge.vim requires at least Vim version 7"
	finish
endif

command! -nargs=* Tabmerge call Tabmerge(<f-args>)

function! Tabmerge(...)  " {{{1
	if a:0 > 2
		echohl ErrorMsg
		echo "Too many arguments"
		echohl None
		return
	elseif a:0 == 2
		let tabnr = a:1
		let where = a:2
	elseif a:0 == 1
		if a:1 =~ '^\d\+$' || a:1 == '$'
			let tabnr = a:1
		else
			let where = a:1
		endif
	endif

	if !exists('l:where')
		let where = 'top'
	endif

	if !exists('l:tabnr')
		if type(tabpagebuflist(tabpagenr() + 1)) == 3
			let tabnr = tabpagenr() + 1
		elseif type(tabpagebuflist(tabpagenr() - 1)) == 3
			let tabnr = tabpagenr() - 1
		else
			echohl ErrorMsg
			echo "Already only one tab"
			echohl None
			return
		endif
	endif

	if tabnr == '$'
		let tabnr = tabpagenr(tabnr)
	else
		let tabnr = tabnr
	endif

	let tabwindows = tabpagebuflist(tabnr)

	if type(tabwindows) == 0 && tabwindows == 0
		echohl ErrorMsg
		echo "No such tab number: " . tabnr
		echohl None
		return
	elseif tabnr == tabpagenr()
		echohl ErrorMsg
		echo "Can't merge with the current tab"
		echohl None
		return
	endif

	if where =~? '^t\(op\)\?$'
		let where = 'topleft'
	elseif where =~? '^b\(ot\(tom\)\?\)\?$'
		let where = 'botright'
	elseif where =~? '^l\(eft\)\?$'
		let where = 'leftabove vertical'
	elseif where =~? '^r\(ight\)\?$'
		let where = 'rightbelow vertical'
	else
		echohl ErrorMsg
		echo "Invalid location: " . a:2
		echohl None
		return
	endif

	let save_switchbuf = &switchbuf
	let &switchbuf = ''

	if where == 'top'
		let tabwindows = reverse(tabwindows)
	endif

	for buf in tabwindows
		exe where . ' sbuffer ' . buf
	endfor

	exe 'tabclose ' . tabnr

	let &switchbuf = save_switchbuf
endfunction

" vim:fdm=marker:fdc=2:fdl=1:
