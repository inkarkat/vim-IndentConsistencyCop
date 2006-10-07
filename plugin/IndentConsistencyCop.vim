" tabcontrol.vim: does the buffer's indentation conform to tab settings?
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" ASSUMPTIONS:
" - When using 'softtabtop', 'tabstop' remains at the standard value of 8. 
"   Any other value would sort of undermine the idea of 'softtabstop', anyway. 
" - The indentation value lies in the range of 1-8 spaces or is 1 tab. 
"
" REVISION	DATE		REMARKS 
"	0.01	08-Oct-2006	file creation

" Avoid installing twice or when in compatible mode
if exists("loaded_tabcontrol") || (v:version < 700)
    finish
endif
let loaded_tabcontrol = 1

function! s:IncreaseKeyBy( dict, key, num )
"****D echo '**** ' . a:key
    if has_key( a:dict, a:key )
	let a:dict[ a:key ] += a:num
    else
	let a:dict[ a:key ] = a:num
    endif
endfunction

function! s:IncreaseKey( dict, key )
    call s:IncreaseKeyBy( a:dict, a:key, 1 )
endfunction

function! s:EvaluateIndentsIntoOccurrences( dict, type )
    for l:indent in keys( a:dict )
	let l:indentCnt = 8
	while l:indentCnt > 0
	    if l:indent % l:indentCnt == 0
		call s:IncreaseKeyBy( s:occurrences, a:type . l:indentCnt, a:dict[ l:indent ] )
	    endif
	    let l:indentCnt -= 1
	endwhile
    endfor
endfunction

function! s:TabControl()
    let s:occurrences = {}
    let s:spaces = {}
    let s:softtabstops = {}

    let l:lineNum = 1
    while l:lineNum <= line('$')
	call s:InspectLine(l:lineNum)
	let l:lineNum += 1
    endwhile

    call s:EvaluateIndentsIntoOccurrences( s:spaces, 'sp' )
    call s:EvaluateIndentsIntoOccurrences( s:softtabstops, 'sts' )
    echo s:spaces
    echo s:softtabstops
    echo s:occurrences

    echo 'This is probably a ' . string( filter( copy( s:occurrences ), 'v:val == max( s:occurrences )') )
endfunction

function! s:InspectLine(lineNum)
"****D echo getline(a:lineNum)
    let l:beginningWhitespace = matchstr( getline(a:lineNum), '^\s*' )
    if l:beginningWhitespace == ''
	return
    elseif match( l:beginningWhitespace, '^\t\+$' ) != -1
	call s:CountTabs( l:beginningWhitespace )
	" Tabs-only can also be interpreted as a softtabstop-line without
	" balancing spaces. 
	call s:CountSofttabstops( l:beginningWhitespace )
    elseif match( l:beginningWhitespace, '^ \{1,7}$' ) != -1
	call s:CountSpaces( l:beginningWhitespace )
	" Spaces-only (up to 7) can also be interpreted as a softtabstop-line
	" without tabs. 
	call s:CountSofttabstops( l:beginningWhitespace )
    elseif match( l:beginningWhitespace, '^ \{8,}$' ) != -1
	call s:CountSpaces( l:beginningWhitespace )
    elseif match( l:beginningWhitespace, '^\t\+ \{1,7}$' ) != -1
	call s:CountSofttabstops( l:beginningWhitespace )
    elseif match( l:beginningWhitespace, '^\t\+ \{8,}$' ) != -1
	call s:CountBadSofttabstop( l:beginningWhitespace )
    else
	call s:CountBadMixOfSpacesAndTabs( l:beginningWhitespace )
    endif
endfunction

function! s:CountTabs( tabString )
    call s:IncreaseKey( s:occurrences, 'ts' )
endfunction

function! s:CountSpaces( spaceString )
    call s:IncreaseKey( s:spaces, len( a:spaceString ) )
endfunction

function! s:CountSofttabstops( stsString )
    call s:IncreaseKey( s:softtabstops, len( substitute( a:stsString, '\t', '        ', 'g' ) ) )
endfunction

function! s:CountBadSofttabstop( string )
    call s:IncreaseKey( s:occurrences, 'badsts')
endfunction

function! s:CountBadMixOfSpacesAndTabs( string )
    call s:IncreaseKey( s:occurrences, 'badmix')
endfunction

"TODO: range-command
command! -nargs=0 TabControl call <SID>TabControl()

