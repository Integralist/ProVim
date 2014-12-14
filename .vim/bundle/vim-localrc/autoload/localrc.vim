" Enable configuration file of each directory.
" Version: 0.2.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim


function! localrc#load(fnames, ...)
  for file in localrc#search(a:fnames,
  \                          1 <= a:0 ? a:1 : expand('%:p:h'),
  \                          2 <= a:0 ? a:2 : -1)
    " XXX: Handle error?
    source `=file`
  endfor
endfunction

function! localrc#search(fnames, ...)
  let path = 1 <= a:0 ? a:1 : expand('%:p:h')
  if empty(a:fnames) || !isdirectory(path)
    return []
  endif

  let depth = 2 <= a:0 ? a:2 : -1
  let targets = []
  let dir = fnamemodify(path, ':p:h')
  let updir = ''
  while depth != 0 && dir !=# updir
    let targets = s:match_files(dir, a:fnames) + targets
    let updir = dir
    let dir = fnamemodify(dir, ':h')
    if (has('win32') || has('win64')) && dir =~ '^\\\\[^\\]\+$'
      break
    endif
    let depth -= 1
  endwhile
  return targets
endfunction

function! s:match_files(path, fname)
  if type(a:fname) == type([])
    let files = []
    for f in a:fname
      let files += s:match_files(a:path, f)
    endfor
    return s:uniq(files)
  endif

  let path = escape(a:path, '*?[,')
  if a:fname[0] == '/'
    let files = split(globpath(path, '/.*', 1), "\n")
    \         + split(globpath(path, '/*' , 1), "\n")
    let pat = a:fname[1:]
    call filter(map(files, 'fnamemodify(v:val, ":t")'), 'v:val =~# pat')

  else
    let files = map(split(globpath(path, a:fname, 1), "\n"),
    \               'fnamemodify(v:val, ":t")')
  endif

  return filter(map(files, 'a:path . "/" . v:val'), 'filereadable(v:val)')
endfunction

" - string only.
" - can not treat a empty string.
function! s:uniq(list)
  let i = 0
  let len = len(a:list)
  let seen = {}
  while i < len
    if has_key(seen, a:list[i])
      call remove(a:list, i)
    else
      let seen[a:list[i]] = 1
      let i += 1
    endif
  endwhile
  return a:list
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
