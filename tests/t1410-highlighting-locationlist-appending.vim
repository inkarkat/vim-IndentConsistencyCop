" Test appending to location list.

let g:indentconsistencycop_highlighting = 'W'
let g:IngoLibrary_ConfirmChoices = ['highlight wrong indents', 'illegal indents only', 'highlight wrong indents', 'not buffer settings']

edit IsFindBadMixEverywhere.txt
IndentConsistencyCop
edit test053.txt
IndentConsistencyCop

call vimtest#StartTap()
call vimtap#Plan(6)
call vimtap#Is(map(getloclist(0), 'v:val.lnum'), [4, 6, 9, 13, 46, 47, 48, 49, 50, 51, 52], 'quickfix line numbers of inconsistent lines')
call vimtap#Is(map(getloclist(0), 'v:val.bufnr'), [1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2], 'quickfix buffers with inconsistent lines')

call vimtap#Is(getloclist(0)[0].text, 'Bad mix of space and tab', 'quickfix text for badmix')
call vimtap#Is(getloclist(0)[0].col, 8, 'quickfix column for badmix')
call vimtap#Is(getloclist(0)[2].text, 'Bad softtabstop', 'quickfix text for badmix')
call vimtap#Is(getloclist(0)[2].col, 3, 'quickfix column for badmix')

call vimtest#Quit()
