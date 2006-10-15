" IndentConsistencyCop.vim: Is the buffer's indentation consistent and does it conform to tab settings?
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" ASSUMPTIONS:
" - When using 'softtabstop', 'tabstop' remains at the standard value of 8. 
"   Any other value would sort of undermine the idea of 'softtabstop', anyway. 
" - The indentation value lies in the range of 1-8 spaces or is 1 tab. 
" - When 'smarttab' is set (global setting), 'tabstop' and 'softtabstop' become
"   irrelevant to front-of-the-line indenting; only 'shiftwidth' counts. 
" - There are two possibilities to model 'expandtab': Either set the indent via
"   'tabstop', or keep 'tabstop=8' and set the indent via 'softtabstop'. 
"   We use the following guideline: 
"   If tabstop is kept at the standard 8, we prefer changing the indent via
"   softtabstop. 
"   If tabstop is non-standard, anyway, we rather modify tabstop than turning on
"   softtabstop. 
"
" REVISION	DATE		REMARKS 
"	0.02	11-Oct-2006	Completed consistency check for complete buffer. 
"				Added check for range of the current buffer. 
"				Added user choice to automatically change buffer settings. 
"				Now correctly handling 'smarttab' and the
"				'expandtab' ambiguity. 
"	0.01	08-Oct-2006	file creation

" Avoid installing twice or when in compatible mode
if exists("loaded_indentconsistencycop") || (v:version < 700)
    finish
endif
let loaded_indentconsistencycop = 1


"- list and dictionary utility functions ---------------------------------{{{1
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

function! s:RemoveFromList( list, value )
    call filter( a:list, 'v:val != "' . a:value . '"' )
endfunction

"- utility functions -----------------------------------------------------{{{1
function! s:IsDivsorOf( newNumber, numbers )
    for l:number in a:numbers
	if l:number % a:newNumber == 0
	    return 1
	endif
    endfor
    return 0
endfunction

function! s:GetMultiplierFromIndentSetting( indentSetting )
    if a:indentSetting == 'tab'
	return 8
    else
	return str2nr( strpart( a:indentSetting, 3 ) )
    endif
endfunction

function! s:GetSettingFromIndentSetting( indentSetting )
    return strpart( a:indentSetting, 0, 3 )
endfunction

"- Processing of lines in buffer -----------------------------------------{{{1
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

function! s:InspectLine(lineNum)
"*******************************************************************************
"* PURPOSE:
"   Count the whitespace at the beginning of the passed line (until the first
"   non-whitespace character) and increase one of the counters. There are two
"   types of counters:
"   1. The master counter s:occurrences can be directly filled with elements
"      like all-Tabs or bad Tab-Space combinations, where the number of Tabs /
"      Spaces doesn't matter. 
"   2. The intermediate counters s:spaces, s:softtabstops and s:doubtful also
"      capture the number of the characters. These counters are later
"      consolidated into s:occurrences. 
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"   updates s:occurrences, s:spaces, s:softtabstops, s:doubtful
"* INPUTS:
"   lineNum: number of line in the current buffer
"* RETURN VALUES: 
"   none
"*******************************************************************************
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

function! s:EvaluateIndentsIntoOccurrences( dict, type ) " {{{1
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

function! s:ApplyPrecedences() " {{{1
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


"- Check for compatible indent settings ----------------------------------{{{1
function! s:IsIndentProduceableWithIndentSetting( indent, indentSetting )
    let l:indentMultiplier = s:GetMultiplierFromIndentSetting( a:indentSetting )
    if l:indentMultiplier == 0
	return 0 " This is for the 'badsts' and 'badmix' indent settings. 
    else
	return (a:indent % l:indentMultiplier == 0)
    endif
endfunction

function! s:InspectForCompatibles( incompatibles, indents, baseIndentSetting, testSetting )
"*******************************************************************************
"* PURPOSE:
"   Uses the passed list of indents to find indent settings in a:testSetting
"   that are compatible with a:baseIndentSetting. 
"   Candidates are: tabs may count as softtabstops, short indents (captured in
"   s:doubtful) may be both softtabstops or spaces. Spaces and softtabstops may
"   have different multipliers (e.g. sts5 and sts3) that may be compatible (e.g.
"   for indents 15, 30, 45). 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   Modifies the passed a:incompatibles. 
"* INPUTS:
"   a:incompatibles: reference to the pre-initialized list of (possibly)
"	incompatibles. Will contain only *real* incompatibles after the function
"	run. 
"   a:indents:	list of actual indents that have occurred in the buffer. 
"	The list should exclude indents that are not caused by
"	a:baseIndentSetting, so that no false positives are found. 
"   a:baseIndentSetting: indent setting (e.g. 'sts6') on which the search for
"	compatibles is based on
"   a:testSetting: setting (e.g. 'sts') which filters the indent settings to be
"	searched for compatibles. 
"* RETURN VALUES: 
"   none
"* EXAMPLES:
"   s:InspectForCompatibles( l:incompatibles, [ 6, 12, 48, 60 ], 'sts6', 'sts' )
"	searches for compatibles to 'sts6' that match 'sts', using the passed
"	indent list. It'll return [ 'sts1', 'sts2', 'sts3' ]. 
"*******************************************************************************
    " Seed possible incompatibles with passed set; filter is testSetting. 
    let l:isIncompatibles = {}	" Key: indentSetting; value: boolean (0/1). 
    for l:incompatible in a:incompatibles
	if s:GetSettingFromIndentSetting( l:incompatible ) == a:testSetting
	    let l:isIncompatibles[ l:incompatible ] = 0
	endif
    endfor

    for l:isIncompatible in keys( l:isIncompatibles )
	for l:indent in a:indents
	    " Find indents all that match l:isIncompatible and test whether is
	    " also matches with a:baseIndentSetting
	    if s:IsIndentProduceableWithIndentSetting( l:indent, l:isIncompatible )
		if ! s:IsIndentProduceableWithIndentSetting( l:indent, a:baseIndentSetting )
		    " Indent isn't compatible, mark as incompatible. 
		    let l:isIncompatibles[ l:isIncompatible ] = 1
		    " We're through with this possible incompatible. 
		    break
		endif
	    endif
	endfor
    endfor

    " Remove the incompatibles that have been found compatible from
    " a:incompatibles. 
    for l:isIncompatible in keys( l:isIncompatibles )
	if ! l:isIncompatibles[ l:isIncompatible ]
	    call s:RemoveFromList( a:incompatibles, l:isIncompatible )
"****D echo '**** ' . l:isIncompatible . ' is actually compatible with ' . a:baseIndentSetting
	endif
    endfor
endfunction

function! s:GetIncompatiblesForIndentSetting( indentSetting )
"*******************************************************************************
"* PURPOSE:
"   This function encodes the straightforward (i.e. general, settings-wide)
"   compatibility rules for the indent settings. Compatibilities that require
"   inspection of the actual indents in the buffer are delegated to
"   s:InspectForCompatibles(). 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES: 
"    list of indent settings.
"*******************************************************************************
    " Start by assuming all indent settings are incompatible. 
    let l:incompatibles = keys( s:occurrences )
    " The indent setting is compatible with itself. 
    call s:RemoveFromList( l:incompatibles, a:indentSetting )

    let l:setting = s:GetSettingFromIndentSetting( a:indentSetting )
    if l:setting == 'tab'
	" 'sts' could be compatible with 'tab'. 
	" softtabstops must be inspected; doubtful contains indents that are too small (<8) for 'tab'. 
"****D echo '**** Inspecting for "tab": ' . string( keys( s:softtabstops ) )
	call s:InspectForCompatibles( l:incompatibles, keys( s:softtabstops ), a:indentSetting, 'sts' )
    elseif l:setting == 'sts'
	" 'tab' is compatible by definition. 
	call s:RemoveFromList( l:incompatibles, 'tab' )
	" 'spc' is incompatible
	" Other 'sts' multipliers could be compatible; softtabstops and doubtful must be inspected. 
"****D echo '**** Inspecting for "sts": ' . string( keys( s:softtabstops ) + keys( s:doubtful ))
	call s:InspectForCompatibles( l:incompatibles, keys( s:softtabstops ) + keys( s:doubtful ), a:indentSetting, 'sts' )
    elseif l:setting == 'spc'
	" 'tab' is incompatible. 
	" 'sts' is incompatible. 
	" Other 'spc' multipliers could be compatible; spaces and doubtful must be inspected. 
"****D echo '**** Inspecting for "spc": ' . string( keys( s:spaces ) + keys( s:doubtful ))
	call s:InspectForCompatibles( l:incompatibles, keys( s:spaces ) + keys( s:doubtful ), a:indentSetting, 'spc' )
    elseif l:setting == 'bad'
	" for bad, all are incompatible. 
    else
	throw 'Unknown indent setting: ' . l:setting
    endif

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

"- Rating generation -----------------------------------------------------{{{1
function! s:EvaluateOccurrenceAndIncompatibleIntoRating( occurrences, incompatibles )
"*******************************************************************************
"* PURPOSE:
"   For each indent setting, calculates a single (unnormalized) rating; the
"   higher, the more probable the indent setting. 
"   The formula is rating( indent setting ) = # of indent setting occurrences /
"   sum( # of occurrences of incompatible indent settings ). 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:occurrences: dictionary of occurences
"   a:incompatibles: dictionary of incompatibles
"* RETURN VALUES: 
"   dictionary of ratings; key: indent setting; value: rating number
"   -1 means a perfect rating (i.e. no incompatibles)
"*******************************************************************************
    let l:ratings = {}
    for l:indentSetting in keys( a:occurrences )
	let l:incompatibles = a:incompatibles[ l:indentSetting ]
	if empty( l:incompatibles )
	    " No incompatibles; this gets the perfect rating. 
	    let l:ratings[ l:indentSetting ] = -1
	else
	    let l:incompatibleOccurrences = 0
	    for l:incompatible in l:incompatibles
		let l:incompatibleOccurrences += a:occurrences[ l:incompatible ]
	    endfor
	    let l:ratings[ l:indentSetting ] = 10000 * a:occurrences[ l:indentSetting ] / l:incompatibleOccurrences
	endif
    endfor
    return l:ratings
endfunction

function! s:IsContainsPerfectRating( ratings )
    let l:perfectCount = count( a:ratings, -1 )
    if l:perfectCount > 1
	throw "assert perfectCount <= 1"
    endif
    return l:perfectCount == 1
endfunction

"- Rating normalization --------------------------------------------------{{{1
function! s:NormalizePerfectRating( ratings )
    for l:rating in keys( a:ratings )
	if a:ratings[ l:rating ] == -1
	    " Normalize to 100%
	    let a:ratings[ l:rating ] = 100
	else
	    unlet a:ratings[ l:rating ] 
	endif
    endfor
endfunction

function! s:IsBadIndentSetting( indentSetting )
    return s:GetSettingFromIndentSetting( a:indentSetting ) == 'bad'
endfunction

function! s:NormalizeNonPerfectRating( ratings )
    let l:ratingThreshold = 10	" Remove everything below this percentage. Exception: indent setting 'bad'. 

    let l:valueSum = 0
    for l:value in values( a:ratings )
	let l:valueSum += l:value
    endfor
    if l:valueSum <= 0 
	throw "assert valueSum > 0"
    endif

    for l:rating in keys( a:ratings )
	let l:newRating = 100 * a:ratings[ l:rating ] / l:valueSum
	if l:newRating < l:ratingThreshold && ! s:IsBadIndentSetting( l:rating )
	    unlet a:ratings[ l:rating ] 
	else
	    let a:ratings[ l:rating ] = l:newRating
	endif
    endfor
endfunction

function! s:NormalizeRatings( ratings )
"*******************************************************************************
"* PURPOSE:
"   Changes the values in the a:ratings dictionary to that the sum of all values
"   is 100; i.e. make percentages out of the ratings. 
"   Values below a certain percentage threshold are dropped from the dictionary
"   *after* the normalization, in order to remove clutter when displaying the
"   results to the user. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"   Modifies values in a:ratings. 
"   Removes entries that fall below the threshold. 
"* INPUTS:
"   a:ratings: Key: indent setting; value: rating number
"* RETURN VALUES: 
"   none
"*******************************************************************************
    if s:IsContainsPerfectRating( a:ratings )
	call s:NormalizePerfectRating( a:ratings )
    else
	call s:NormalizeNonPerfectRating( a:ratings )
    endif
endfunction

function! s:CheckBufferConsistency( startLineNum, endLineNum, occurrences, ratings ) " {{{1
"*******************************************************************************
"* PURPOSE:
"   Checks the consistency of the indents in the current buffer, range of
"   startLine to endLine. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:startLineNum
"   a:endLineNum
"   a:occurrences: empty dictionary
"   a:ratings: empty dictionary
"* RETURN VALUES: 
"   -1: checked range does not contain indents
"    0: checked range is not consistent
"    1: checked range is consistent
"   Fills the a:occurrences dictionary; key: indent setting; value: number of
"	lines that have that indent setting
"   Fills the a:ratings dictionary; key: indent setting; value: percentage 
"	rating (100: checked range is consistent; < 100: inconsistent. 
"*******************************************************************************
    if a:startLineNum > a:endLineNum
	throw assert startLineNum <= a:endLineNum
    endif

    " This dictionary collects the occurrences of all found indent settings. It
    " is the basis for all evaluations and statistics. 
    let s:occurrences = {}  " key: indent setting (e.g. 'sts4'); value: number of lines that have that indent setting. 

    " These intermediate dictionaries will be processed into s:occurences via
    " EvaluateIndentsIntoOccurrences(). 
    let s:spaces = {}	    " key: number of indent spaces (>=8); value: number of lines that have the number of indent spaces. 
    let s:softtabstops = {} " key: number of indent softtabstops (converted to spaces); value: number of lines that have the number of spaces. 
    let s:doubtful = {}	    " key: number of indent spaces (<8) which may be either spaces or softtabstops; value: number of lines that have the number of spaces. 

    let l:lineNum = a:startLineNum
    while l:lineNum <= a:endLineNum
	call s:InspectLine(l:lineNum)
	let l:lineNum += 1
    endwhile

    call s:EvaluateIndentsIntoOccurrences( s:spaces, 'spc' )
    call s:EvaluateIndentsIntoOccurrences( s:softtabstops, 'sts' )
    call s:EvaluateIndentsIntoOccurrences( s:doubtful, 'dbt' )
    " Now, the indent occurences have been consolidated into s:occurrences. 
"****D echo 'Spaces:       ' . string( s:spaces )
"****D echo 'Softtabstops: ' . string( s:softtabstops )
"****D echo 'Doubtful:     ' . string( s:doubtful )
"****D echo 'Occurrences 1:' . string( s:occurrences )

    if empty( s:occurrences )
	return -1
    endif

    call s:ApplyPrecedences()

"****D echo 'Occurrences 2:' . string( s:occurrences )
"****D echo 'This is probably a ' . string( filter( copy( s:occurrences ), 'v:val == max( s:occurrences )') )

    " This dictionary contains the incompatible indent settings for each indent
    " setting. 
    let l:incompatibles = s:EvaluateIncompatibleIndentSettings() " Key: indent setting; value: list of indent settings. 
"****D echo 'Incompatibles:' . string( l:incompatibles )

    " This dictionary contains the final rating, a combination of high indent settings occurrence and low incompatible occurrences. 
    let l:ratings = s:EvaluateOccurrenceAndIncompatibleIntoRating( s:occurrences, l:incompatibles ) " Key: indent setting; value: rating number
"****D echo 'ratings:     ' . string( l:ratings )

    call s:NormalizeRatings( l:ratings )
"****D echo 'nrm. ratings:' . string( l:ratings )


    call extend( a:occurrences, s:occurrences )
    call extend( a:ratings, l:ratings )

    " Cleanup variables with script-scope. 
    call filter( s:occurrences, 0 )
    call filter( s:spaces, 0 )
    call filter( s:softtabstops, 0 )
    call filter( s:doubtful, 0 )

    let l:isConsistent = (count( l:ratings, 100 ) == 1)
    return l:isConsistent
endfunction


"- consistency with buffer settings functions -----------------------------{{{1
function! s:GetCorrectTabstopSetting( indentSetting )
    if &smarttab == 1
	" When using 'smarttab', front-of-the-line indenting solely uses
	" 'shiftwidth'; 'tabstop' and 'softtabstop' are only used in other
	" places. 
	return &l:tabstop
    elseif s:GetSettingFromIndentSetting( a:indentSetting ) == 'tab'
	return &l:tabstop
    elseif s:GetSettingFromIndentSetting( a:indentSetting ) == 'sts'
	return 8
    elseif s:GetSettingFromIndentSetting( a:indentSetting ) == 'spc'
	" If tabstop=8, we prefer changing the indent via softtabstop. 
	" If tabstop!=8, we rather modify tabstop than turning on softtabstop. 
	if &l:tabstop == 8
	    return 8
	else
	    return s:GetMultiplierFromIndentSetting( a:indentSetting )
	endif
    else
	throw "assert false"
    endif
endfunction

function! s:GetCorrectSofttabstopSetting( indentSetting )
    if &smarttab == 1
	" When using 'smarttab', front-of-the-line indenting solely uses
	" 'shiftwidth'; 'tabstop' and 'softtabstop' are only used in other
	" places. 
	return &l:softtabstop
    elseif s:GetSettingFromIndentSetting( a:indentSetting ) == 'sts'
	return s:GetMultiplierFromIndentSetting( a:indentSetting )
    elseif s:GetSettingFromIndentSetting( a:indentSetting ) == 'spc'
	" If tabstop=8, we prefer changing the indent via softtabstop. 
	" If tabstop!=8, we rather modify tabstop than turning on softtabstop. 
	if &l:tabstop == 8 && s:GetMultiplierFromIndentSetting( a:indentSetting ) != 8
	    return s:GetMultiplierFromIndentSetting( a:indentSetting )
	else
	    return 0
	endif
    else
	" Prefers (ts=n sts=0 expandtab) over (ts=8 sts=n expandtab). 
	return 0
    endif
endfunction

function! s:GetCorrectShiftwidthSetting( indentSetting )
    if s:GetSettingFromIndentSetting( a:indentSetting ) == 'tab'
	return &l:tabstop
    else
	return s:GetMultiplierFromIndentSetting( a:indentSetting )
    endif
endfunction

function! s:GetCorrectExpandtabSetting( indentSetting )
    return (s:GetSettingFromIndentSetting( a:indentSetting ) == 'spc')
endfunction

function! s:CheckConsistencyWithBufferSettings( indentSetting ) " {{{2
"*******************************************************************************
"* PURPOSE:
"   Checks the consistency of the passed indent setting with the indent settings
"   of the current buffer, i.e. the 'tabstop', 'softtabstop', 'shiftwidth' and
"   'expandtab' settings. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:indentSettings: prescribed indent setting for the buffer
"* RETURN VALUES: 
"   empty string: indent setting is consistent with buffer indent settings, else
"   user string describing the necessary changes to adapt the buffer indent
"	settings. 
"*******************************************************************************
    let l:isTabstopCorrect     = (s:GetCorrectTabstopSetting( a:indentSetting )	    == &l:tabstop)
    let l:isSofttabstopCorrect = (s:GetCorrectSofttabstopSetting( a:indentSetting ) == &l:softtabstop)
    let l:isShiftwidthCorrect  = (s:GetCorrectShiftwidthSetting( a:indentSetting )  == &l:shiftwidth)
    let l:isExpandtabCorrect   = (s:GetCorrectExpandtabSetting( a:indentSetting )   == &l:expandtab)

    if l:isTabstopCorrect && l:isSofttabstopCorrect && l:isShiftwidthCorrect && l:isExpandtabCorrect
	return ''
    else
	let l:userString = "The buffer's indent settings are inconsistent with the used indent '" . s:IndentSettingToUserString( a:indentSetting ) . "'; these settings must be changed: "
	if ! l:isTabstopCorrect
	    let l:userString .= "\n- tabstop from " . &l:tabstop . ' to ' . s:GetCorrectTabstopSetting( a:indentSetting )
	endif
	if ! l:isSofttabstopCorrect
	    let l:userString .= "\n- softtabstop from " . &l:softtabstop . ' to ' . s:GetCorrectSofttabstopSetting( a:indentSetting )
	endif
	if ! l:isShiftwidthCorrect
	    let l:userString .= "\n- shiftwidth from " . &l:shiftwidth . ' to ' . s:GetCorrectShiftwidthSetting( a:indentSetting )
	endif
	if ! l:isExpandtabCorrect
	    let l:userString .= "\n- expandtab from " . &l:expandtab . ' to ' . s:GetCorrectExpandtabSetting( a:indentSetting )
	endif

	return l:userString
    endif
endfunction " }}}2

function! s:MakeBufferSettingsConsistentWith( indentSetting )
    let &l:tabstop    = s:GetCorrectTabstopSetting( a:indentSetting )
    let &l:softtabstop = s:GetCorrectSofttabstopSetting( a:indentSetting )
    let &l:shiftwidth = s:GetCorrectShiftwidthSetting( a:indentSetting )
    let &l:expandtab  = s:GetCorrectExpandtabSetting( a:indentSetting )
endfunction

"- output functions -------------------------------------------------------{{{1
function! s:IndentSettingToUserString( indentSetting )
"*******************************************************************************
"* PURPOSE:
"   Converts the internally used 'xxxn' indent setting into a
"   user-understandable string. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:indentSetting: indent setting
"* RETURN VALUES: 
"   string describing the indent setting
"*******************************************************************************
    let l:userString = ''

    if a:indentSetting == 'tab' 
	let l:userString = 'tabstop'
    elseif a:indentSetting == 'badsts'
	let l:userString = 'soft tabstop with too many trailing spaces'
    elseif a:indentSetting == 'badmix'
	let l:userString = 'bad mix of spaces and tabs'
    else
	let l:setting = s:GetSettingFromIndentSetting( a:indentSetting )
	let l:multiplier = s:GetMultiplierFromIndentSetting( a:indentSetting )
	if l:setting == 'sts'
	    let l:userString = l:multiplier . ' characters soft tabstop' 
	elseif l:setting == 'spc'
	    let l:userString = l:multiplier . ' spaces'
	else
	    throw 'assert false'
	endif
    endif

    return l:userString
endfunction

function! s:DictCompareDescending( i1, i2 )
    return a:i1[1] == a:i2[1] ? 0 : a:i1[1] > a:i2[1] ? -1 : 1
endfunction

function! s:RatingsToUserString( occurrences, ratings, lineCnt )
"*******************************************************************************
"* PURPOSE:
"   Dresses up the ratings information into a multi-line string that can be
"   displayed to the user. The lines are ordered from high to low ratings. If
"   low ratings have been filtered out, this is reported, too. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES: 
"	? Explanation of the value returned.
"*******************************************************************************
    let l:userString = ''

    " In order to output the ratings from highest to lowest, we need to
    " convert the ratings dictionary to a list and sort it with a custom
    " comparator which considers the value part of each list element. 
    " There is no built-in sort() function for dictionaries. 
    let l:ratingLists = items( a:ratings )
    call sort( l:ratingLists, "s:DictCompareDescending" )
    let l:ratingSum = 0
    for l:ratingList in l:ratingLists
	let l:indentSetting = l:ratingList[0]
	let l:userString .= "\n- " . s:IndentSettingToUserString( l:indentSetting ) . ' (' . a:occurrences[ l:indentSetting ] . ' of ' . a:lineCnt . ' lines)'
	"**** l:rating = l:ratingLists[1] = a:ratings[ l:indentSetting ]
	let l:ratingSum += a:ratings[ l:indentSetting ]
    endfor

    if l:ratingSum < (100 - 1) " Allow for 1% rounding error. 
	let l:userString .= "\nSome minor / inconclusive potential settings have been omitted. "
    endif

    return l:userString
endfunction

function! s:PrintBufferSettings( messageIntro )
    let l:userMessage = a:messageIntro
    let l:userMessage .= 'tabstop=' . &l:tabstop . ' softtabstop=' . &l:softtabstop . ' shiftwidth=' . &l:shiftwidth
    let l:userMessage .= (&l:expandtab ? ' expandtab' : ' noexpandtab')

    echomsg l:userMessage
endfunction

function! s:IndentBufferConsistencyCop( scopeUserString, consistentIndentSetting, isBufferSettingsCheck ) " {{{1
"*******************************************************************************
"* PURPOSE:
"   Reports buffer consistency and (if desired) triggers the consistency check
"   with the buffer indent settings, thereby interacting with the user. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:scopeUserString: either 'range' or 'buffer'
"   a:consistentIndentSetting: determined consistent indent setting of the
"      buffer
"   a:isBufferSettingsCheck: flag whether consistency with the buffer
"	settings should also be checked. 
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:userMessage = ''
    if a:isBufferSettingsCheck
	let l:userMessage = s:CheckConsistencyWithBufferSettings( a:consistentIndentSetting )
	if ! empty( l:userMessage )
	    let l:userMessage .= "\nHow do you want to deal with the inconsistency?"
	    let l:actionNum = confirm( l:userMessage, "&Ignore\n&Change" )
	    if l:actionNum <= 1
		call s:PrintBufferSettings( 'The buffer settings remain inconsistent: ' )
	    elseif l:actionNum == 2
		call s:MakeBufferSettingsConsistentWith( a:consistentIndentSetting )
		call s:PrintBufferSettings( 'The buffer settings have been changed: ' )
	    endif
	endif
    endif
    if empty( l:userMessage )
	echomsg 'The indentation in this ' . a:scopeUserString . " is consistently based on the '" . s:IndentSettingToUserString( a:consistentIndentSetting ) . "' setting; it is consistent with the buffer indent settings. "
    endif
endfunction

function! s:IndentConsistencyCop( startLineNum, endLineNum, isBufferSettingsCheck ) " {{{1
"*******************************************************************************
"* PURPOSE:
"   Triggers the indent consistency check and presents the results to the user. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:startLineNum, a:endLineNum: range in the current buffer that is to be
"	checked. 
"   a:isBufferSettingsCheck: flag whether consistency with the buffer
"	settings should also be checked. 
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:isEntireBuffer = ( a:startLineNum == 1 && a:endLineNum == line('$') )
    let l:scopeUserString = (l:isEntireBuffer ? 'buffer' : 'range')
    let l:lineCnt = a:endLineNum - a:startLineNum + 1

    let l:occurrences = {}
    let l:ratings = {}
    let l:isConsistent = s:CheckBufferConsistency( a:startLineNum, a:endLineNum, l:occurrences, l:ratings )

    if l:isConsistent == -1
	echomsg 'This ' . l:scopeUserString . ' does not contain indented text. '
    elseif l:isConsistent == 0
	call confirm( 'Found inconsistent indentation in this ' . l:scopeUserString . '; possibly generated from these conflicting settings: ' . s:RatingsToUserString( l:occurrences, l:ratings, l:lineCnt ) )
    elseif l:isConsistent == 1
	let l:consistentIndentSetting = keys( l:ratings )[0]
	call s:IndentBufferConsistencyCop( l:scopeUserString, l:consistentIndentSetting, a:isBufferSettingsCheck )
    else
	throw "assert false"
    endif
"****D echo 'Consistent   ? ' . l:isConsistent
"****D echo 'Occurrences:   ' . string( l:occurrences )
"****D echo 'nrm. ratings:  ' . string( l:ratings )
endfunction

"- commands --------------------------------------------------------------{{{1
" Only check indent consistency within range / buffer. Don't check the
" consistency with buffer indent settings. 
command! -range=% -nargs=0 IndentRangeConsistencyCop call <SID>IndentConsistencyCop( <line1>, <line2>, 0 )

" Ensure indent consistency within the range / buffer, and - if achieved -, also
" check consistency with buffer indent settings. 
command! -range=% -nargs=0 IndentConsistencyCop call <SID>IndentConsistencyCop( <line1>, <line2>, 1 )

" vim:ft=vim foldmethod=marker
