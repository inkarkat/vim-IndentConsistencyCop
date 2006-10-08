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

function! s:IncreaseKeyedBy( dict, key, num )
"****D echo '**** ' . a:key
    if has_key( a:dict, a:key )
	let a:dict[ a:key ] += a:num
    else
	let a:dict[ a:key ] = a:num
    endif
endfunction

function! s:IncreaseKeyed( dict, key )
    call s:IncreaseKeyedBy( a:dict, a:key, 1 )
endfunction

function! s:GetKeyedValue( dict, key )
    if has_key( a:dict, a:key )
	return a:dict[a:key]
    else
	return 0
endfunction

function! s:RemoveKey( dict, key )
    if has_key( a:dict, a:key )
	unlet a:dict[a:key]
    endif
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
		    call s:IncreaseKeyedBy( s:occurrences, a:type . l:indentCnt, a:dict[ l:indent ] )
		"****D else
		    "****D echo "**** " . l:indent . " discarding " . l:indentCnt . " because already done " . string(l:divisors)
		endif
		let l:divisors += [ l:indentCnt ]
	    endif
	    let l:indentCnt -= 1
	endwhile
    endfor
endfunction

function! s:ApplyPrecedences()
"*******************************************************************************
"* PURPOSE:
"   Relates individual indent settings to others, thereby "stronger" indent
"   settings take precedent over "weaker" ones. 
"* ASSUMPTIONS / PRECONDITIONS:
"   s:occurrences contains consolidated indent occurrences. 
"* EFFECTS / POSTCONDITIONS:
"   Modifies s:occurrences. 
"* INPUTS:
"   none
"* RETURN VALUES: 
"   none
"*******************************************************************************
    " Space indents of up to 7 spaces can be either softtabstop or space-indent,
    " and have been collected in the 'dbt n' keys so far. 
    " If there is only either 'sts n' or 'spc n', the 'dbt n' value is moved to
    " that key. If both exist, its value is added to both. If both are zero /
    " non-existing, the 'dbt n' value is moved to 'spc n'; without further
    " evidence, spaces take precedence over softtabstops. 
    let l:indentCnt = 8
    while l:indentCnt > 0
	let l:dbtKey = 'dbt' . l:indentCnt
	let l:dbt = s:GetKeyedValue( s:occurrences, l:dbtKey )
	if l:dbt > 0
	    let l:spcKey = 'spc' . l:indentCnt
	    let l:stsKey = 'sts' . l:indentCnt
	    let l:spc = s:GetKeyedValue( s:occurrences, l:spcKey )
	    let l:sts = s:GetKeyedValue( s:occurrences, l:stsKey )
	    if l:spc == 0 && l:sts == 0
		call s:IncreaseKeyedBy( s:occurrences, l:spcKey, l:dbt )
	    else
		if l:spc > 0
		    call s:IncreaseKeyedBy( s:occurrences, l:spcKey, l:dbt )
		endif
		if l:sts > 0
		    call s:IncreaseKeyedBy( s:occurrences, l:stsKey, l:dbt )
		endif
	    endif
	    call s:RemoveKey( s:occurrences, l:dbtKey )
	endif

	let l:indentCnt -= 1
    endwhile

    " The occurrence 'sts8' has only been collected because of the parallelism
    " with 'spc8'. Effectively, 'sts8' is the same as 'tab', and is removed. 
    if s:GetKeyedValue( s:occurrences, 'sts8' ) != s:GetKeyedValue( s:occurrences, 'tab' )
	throw "assert sts8 == tab"
    endif
    call s:RemoveKey( s:occurrences, 'sts8' )
endfunction

function! s:GetIncompatiblesForIndentSetting( indentSetting )
    let l:incompatibles = [ 'xxx' . a:indentSetting ]
    return l:incompatibles
endfunction

function! s:EvaluateIncompatibleIndentSettings()
"*******************************************************************************
"* PURPOSE:
"   Each found indent setting (in s:occurrences) may be compatible with another
"   (e.g. 'sts4' could be unified with 'sts6', if the actual indents found in
"   s:softtabstops and s:doubtful are 12 and 24 (but not 6, 18)). To do this
"   evaluation, the actual indents in s:spaces, s:softtabstops and s:doubtful
"   must be inspected. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.; value: list of
"	indent settings. 
"* RETURN VALUES: 
"    Key: indent setting; value: list of indent settings.
"*******************************************************************************
    let l:incompatibles = {}
    for l:indentSetting in keys( s:occurrences )
	let l:incompatibles[ l:indentSetting ] = s:GetIncompatiblesForIndentSetting( l:indentSetting )
    endfor
    return l:incompatibles
endfunction

function! s:TabControl()
    " This dictionary collects the occurrences of all found indent settings. It
    " is the basis for all evaluations and statistics. 
    let s:occurrences = {}  " key: indent setting (e.g. 'sts4'); value: number of lines that have that indent setting. 

    " These intermediate dictionaries will be processed into s:occurences via
    " EvaluateIndentsIntoOccurrences(). 
    let s:spaces = {}	    " key: number of indent spaces (>=8); value: number of lines that have the number of indent spaces. 
    let s:softtabstops = {} " key: number of indent softtabstops (converted to spaces); value: number of lines that have the number of spaces. 
    let s:doubtful = {}	    " key: number of indent spaces (<8) which may be either spaces or softtabstops; value: number of lines that have the number of spaces. 

    let l:lineNum = 1
    while l:lineNum <= line('$')
	call s:InspectLine(l:lineNum)
	let l:lineNum += 1
    endwhile

    call s:EvaluateIndentsIntoOccurrences( s:spaces, 'spc' )
    call s:EvaluateIndentsIntoOccurrences( s:softtabstops, 'sts' )
    call s:EvaluateIndentsIntoOccurrences( s:doubtful, 'dbt' )
    " Now, the indent occurences have been consolidated into s:occurrences. 
    echo 'Spaces:       ' . string( s:spaces )
    echo 'Softtabstops: ' . string( s:softtabstops )
    echo 'Doubtful:     ' . string( s:doubtful )
    echo 'Occurrences 1:' . string( s:occurrences )

    call s:ApplyPrecedences()

    echo 'Occurrences 2:' . string( s:occurrences )
    echo 'This is probably a ' . string( filter( copy( s:occurrences ), 'v:val == max( s:occurrences )') )

    " This dictionary contains the incompatible indent settings for each indent
    " setting. 
    let l:incompatibles = s:EvaluateIncompatibleIndentSettings() " Key: indent setting; value: list of indent settings. 
    echo 'Incompatibles:' . string( l:incompatibles )
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
	" Spaces-only (up to 7) can also be interpreted as a softtabstop-line
	" without tabs. 
	call s:CountDoubtful( l:beginningWhitespace )
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
    call s:IncreaseKeyed( s:occurrences, 'tab' )
endfunction

function! s:CountDoubtful( spaceString )
    call s:IncreaseKeyed( s:doubtful, len( a:spaceString ) )
endfunction

function! s:CountSpaces( spaceString )
    call s:IncreaseKeyed( s:spaces, len( a:spaceString ) )
endfunction

function! s:CountSofttabstops( stsString )
    call s:IncreaseKeyed( s:softtabstops, len( substitute( a:stsString, '\t', '        ', 'g' ) ) )
endfunction

function! s:CountBadSofttabstop( string )
    call s:IncreaseKeyed( s:occurrences, 'badsts')
endfunction

function! s:CountBadMixOfSpacesAndTabs( string )
    call s:IncreaseKeyed( s:occurrences, 'badmix')
endfunction

"TODO: range-command
command! -nargs=0 TabControl call <SID>TabControl()

