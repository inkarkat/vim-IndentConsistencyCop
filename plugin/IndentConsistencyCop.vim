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

function s:TabControl()
    let l:lineNum = 1
    while l:lineNum <= line('$')
	call s:InspectLine(l:lineNum)
	let l:lineNum += 1
    endwhile
endfunction

function s:InspectLine(lineNum)
    let l:beginningWhitespace = matchstr( getline(a:lineNum), '^\s*' )
    if l:beginningWhitespace == ''
	return
    elseif match( l:beginningWhitespace, '^\t\+$' ) != -1
	" tabs
    elseif match( l:beginningWhitespace, '^ \+$' ) != -1
	" spaces
    elseif match( l:beginningWhitespace, '^\t\+ \{1,7}$' ) != -1
	" softtabstop
    elseif match( l:beginningWhitespace, '^\t\+ \{8,}$' ) != -1
	" bad softtabstop
    else
	" bad mix of spaces and tabs
    endif
endfunction

command! -nargs=0 TabControl call <SID>TabControl()

