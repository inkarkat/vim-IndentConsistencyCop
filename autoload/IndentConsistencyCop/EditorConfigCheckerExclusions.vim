" IndentConsistencyCop/EditorConfigCheckerExclusions.vim: Exclude lines marked with editorconfig-checker exclusion comments.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2026 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! IndentConsistencyCop#EditorConfigCheckerExclusions#Filter( startLnum, endLnum ) abort
    let l:filteredLnums = {}
    let l:lnum = a:startLnum
    let l:isDisabled = 0
    while l:lnum <= a:endLnum
	let l:line = getline(l:lnum)
	if l:lnum == 1 && l:line =~# '\<editorconfig-checker-disable-file\>'
	    return ingo#collections#ToDict(range(a:startLnum, a:endLnum))
	elseif l:isDisabled
	    let l:filteredLnums[l:lnum] = 1
	elseif l:line =~# '\<editorconfig-checker-disable-line\>'
	    let l:filteredLnums[l:lnum] = 1
	elseif l:line =~# '\<editorconfig-checker-disable-next-line\>'
	    let l:filteredLnums[l:lnum + 1] = 1
	elseif l:line =~# '\<editorconfig-checker-disable\>'
	    let l:filteredLnums[l:lnum] = 1
	    let l:isDisabled = 1
	elseif l:line =~# '\<editorconfig-checker-enable\>'
	    let l:isDisabled = 0
	endif

	let l:lnum += 1
    endwhile

    return l:filteredLnums
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
