" IndentConsistencyCop/BlockAlignment.vim: Exclude lines that are aligned as a block.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! IndentConsistencyCop#BlockAlignment#Filter( startLnum, endLnum )
"******************************************************************************
"* PURPOSE:
"   Handle alignment to previous keywords, e.g.
"       <foo bar="baz"
"            quux="new"
"            class="special">
"   and also alignment to common constructs like round / square / curly brackets
"   and quotes, e.g.:
"       function foo([1, 2, 3],
"                    baz,
"                    quux)
"       {
"           // Implementation
"       }
"******************************************************************************
    let l:filteredLnums = {}
    let l:lnum = a:startLnum
    while l:lnum < a:endLnum    " Can ignore last line because there are no subsequent lines then.
	let l:whitespace = IndentConsistencyCop#GetBeginningWhitespace(l:lnum + 1, 0)

	if l:whitespace =~# '^\t\+ \{0,7}$'
	    let l:indent = len(substitute(l:whitespace, '\t', '        ', 'g'))
	elseif l:whitespace =~# '^ \+$'
	    let l:indent = len(l:whitespace)
	else
	    let l:lnum += 1
	    continue
	endif

	if getline(l:lnum) =~# '\S.\{-}\%' . (l:indent + 1) . 'v\%(\<\|[[({''"`]\)'
	    let l:lnum += 1
	    let l:filteredLnums[l:lnum] = 1 " Add first line of block-indent to filter list.
	    while l:lnum < a:endLnum    " And check whether following lines belong to the same block.
		if IndentConsistencyCop#GetBeginningWhitespace(l:lnum + 1, 0) !=# l:whitespace
		    break
		endif
		let l:lnum += 1
		let l:filteredLnums[l:lnum] = 1 " Add subsequent line of block-indent to filter list.
	    endwhile
	else
	    let l:lnum += 1
	endif
    endwhile

    return l:filteredLnums
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
