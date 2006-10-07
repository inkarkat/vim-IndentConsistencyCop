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

function! s:IncreaseKey( key )
echo '**** ' . a:key
    if has_key( s:occurrences, a:key )
	let s:occurrences[ a:key ] += 1
    else
	let s:occurrences[ a:key ] = 1
    endif
endfunction

function! s:TabControl()
    let s:occurrences = {}

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
    call s:IncreaseKey( 'ts' )
endfunction

function! s:CountSpaces( spaceString )
    call s:IncreaseKey( 'sp' . len( a:spaceString ) )
endfunction

function! s:CountSofttabstops( stsString )
    call s:IncreaseKey( 'sts' . len( substitute( a:stsString, '\t', '        ', 'g' ) ) )
endfunction

function! s:CountBadSofttabstop( string )
    call s:IncreaseKey('badsts')
endfunction

function! s:CountBadMixOfSpacesAndTabs( string )
    call s:IncreaseKey('badmix')
endfunction

"TODO: range-command
command! -nargs=0 TabControl call <SID>TabControl()

