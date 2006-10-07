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

function! s:TabControl()
    let s:occurrences = {'ts': 0, 'sp1': 0, 'sp2': 0, 'sp3': 0, 'sp4': 0, 'sp5': 0, 'sp6': 0, 'sp7': 0, 'sp8': 0, 'sts1': 0, 'sts2': 0, 'sts3': 0, 'sts4': 0, 'sts5': 0, 'sts6': 0, 'sts7': 0, 'sts8': 0, 'badsts': 0, 'badmix': 0}

    let l:lineNum = 1
    while l:lineNum <= line('$')
	call s:InspectLine(l:lineNum)
	let l:lineNum += 1
    endwhile
    echo s:occurrences
endfunction

function! s:InspectLine(lineNum)
echo getline(a:lineNum)
    let l:beginningWhitespace = matchstr( getline(a:lineNum), '^\s*' )
    if l:beginningWhitespace == ''
	return
    elseif match( l:beginningWhitespace, '^\t\+$' ) != -1
	call s:CountTabs( l:beginningWhitespace )
    elseif match( l:beginningWhitespace, '^ \+$' ) != -1
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
    let s:occurrences["ts"] += 1
echo '****ts'
endfunction

function! s:CountSpacesWithType( type, spaceString )
    let l:indentCnt = 8
    while l:indentCnt > 0
	if len( a:spaceString ) % l:indentCnt == 0
	    let s:occurrences[ a:type . l:indentCnt ] += 1
echo '****' . a:type . l:indentCnt
	    break
	endif
	let l:indentCnt -= 1
    endwhile
endfunction

function! s:CountSpaces( spaceString )
    call s:CountSpacesWithType( 'sp', a:spaceString )
endfunction

function! s:CountSofttabstops( stsString )
    call s:CountSpacesWithType( 'sts', substitute( a:stsString, '\t', '        ', 'g' ) )
endfunction

function! s:CountBadSofttabstop( string )
    let s:occurrences['badsts'] += 1
endfunction

function! s:CountBadMixOfSpacesAndTabs( string )
    let s:occurrences['badmix'] += 1
endfunction

"TODO: range-command
command! -nargs=0 TabControl call <SID>TabControl()

