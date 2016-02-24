" Test highlighting folds away consistent parts and restores all closed.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit folded.txt
setlocal foldlevel=0
IndentConsistencyCop

call vimtest#StartTap()
call vimtap#Plan(7)
call vimtap#Is(&l:foldlevel, 0, 'folds all still closed')
call vimtap#Is(foldclosedend(2), 6, 'above folded')
call vimtap#Is(foldclosedend(7), -1, 'start unfolded context')
call vimtap#Is(foldclosedend(13), -1, 'end unfolded context')
call vimtap#Is(foldclosedend(14), 15, 'below folded')

IndentConsistencyCopOff
call vimtap#Is(&l:foldlevel, 0, 'foldlevel kept 0')
call vimtap#Is(foldclosedend(2), 13, 'level 1 fold closed')

call vimtest#Quit()
