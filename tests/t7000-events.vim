" Test issuing user events.

let g:eventCnt = 0
autocmd User IndentConsistencyCop let g:eventCnt += 1

call vimtest#StartTap()
call vimtap#Plan(3)

edit test051.txt
let g:IngoLibrary_ConfirmChoices = ['highlight', 'not best guess']
IndentConsistencyCop
call vimtap#Is(g:eventCnt, 1, 'Event from :IndentConsistencyCop')

1,10IndentRangeConsistencyCop
call vimtap#Is(g:eventCnt, 2, 'Event from :1,10IndentRangeConsistencyCop')

IndentConsistencyCopOff
call vimtap#Is(g:eventCnt, 3, 'Event from :IndentConsistencyCopOff')

call vimtest#Quit()
