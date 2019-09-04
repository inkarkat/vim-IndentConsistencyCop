" IndentConsistencyCop/Pattern.vim: Exclude lines based on regular expression match and optionally syntax item name.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! IndentConsistencyCop#Pattern#Filter( startLnum, endLnum ) abort
    let l:filteredLnums = {}
    let l:lnum = a:startLnum
    while l:lnum < a:endLnum
	let l:line = getline(l:lnum)
	for l:pattern in ingo#plugin#setting#GetBufferLocal('IndentConsistencyCop_IgnorePatterns')
	    let l:isSimplePattern = (type(l:pattern) != type([]))
	    if l:line !~# (l:isSimplePattern ? l:pattern : l:pattern[0])
		continue
	    endif
	    if ! l:isSimplePattern
		if ! exists('g:syntax_on') | continue | endif

		let l:matchedText = matchstr(l:line, l:pattern[0])
		if ! IndentConsistencyCop#IsOnSyntax(l:lnum, len(l:matchedText) + 1, l:pattern[1:])
		    continue
		endif
	    endif

	    let l:filteredLnums[l:lnum] = 1
	endfor

	let l:lnum += 1
    endwhile

    return l:filteredLnums
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
