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

function! s:IsDivsorOf( newNumber, numbers )
    for l:number in a:numbers
	if l:number % a:newNumber == 0
	    return 1
	endif
    endfor
    return 0
endfunction

function! s:EvaluateIndentsIntoOccurrences( dict, type )
"*******************************************************************************
"* PURPOSE:
"   An actual indent x translates into occurrences for shiftwidths n, 
"   where n is a divisor of x. Divisors that are divisors of other divisors are
"   skipped. 
"   e.g. indent of 18 -> shiftwidth of 6 (1,2,3 skipped)
"	 indent of 21 -> shiftwidths of 7,3 (1 skipped)
"	 indent of 17 -> shiftwidth of 1
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   dict: the dictionary of actual indents for a particular type
"   type: either 'spc' or 'sts'
"* RETURN VALUES: 
"   Modifies the passed dict reference. 
"*******************************************************************************
    for l:indent in keys( a:dict )
	let l:divisors = []
	let l:indentCnt = 8
	while l:indentCnt > 0
	    if l:indent % l:indentCnt == 0
		if ! s:IsDivsorOf( l:indentCnt, l:divisors )
		    "****D echo "**** " . l:indent . " adding " . l:indentCnt
		    call s:IncreaseKeyBy( s:occurrences, a:type . l:indentCnt, a:dict[ l:indent ] )
		"****D else
		    "****D echo "**** " . l:indent . " discarding " . l:indentCnt . " because already done " . string(l:divisors)
		endif
		let l:divisors += [ l:indentCnt ]
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

    call s:EvaluateIndentsIntoOccurrences( s:spaces, 'spc' )
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
	" If we discarded this, we would neglect to count an indent of 10 tabs
	" (= 80 characters) as 16 * sts5 (the 10 * sts8 will be dropped by the
	" preference of tab over sts8, though). 
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
    call s:IncreaseKey( s:occurrences, 'tab' )
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

