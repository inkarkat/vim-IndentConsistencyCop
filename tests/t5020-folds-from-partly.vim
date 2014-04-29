" Test highlighting folds away consistent parts and restores partly closed.

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

edit folded.txt
setlocal foldlevel=1
IndentConsistencyCop

call vimtest#StartTap()
call vimtap#Plan(10)
call vimtap#Is(&l:foldlevel, 0, 'folds all closed')
call vimtap#Is(foldclosedend(2), 6, 'above folded')
call vimtap#Is(foldclosedend(7), -1, 'start unfolded context')
call vimtap#Is(foldclosedend(13), -1, 'end unfolded context')
call vimtap#Is(foldclosedend(14), 15, 'below folded')

IndentConsistencyCopOff
call vimtap#Is(&l:foldlevel, 1, 'foldlevel restored')
call vimtap#Is(foldclosedend(2), -1, 'level 1 fold open')
call vimtap#Is(foldclosedend(3), 8, 'level 2 fold closed')
call vimtap#Is(foldclosedend(9), 10, 'level 2 fold closed')
call vimtap#Is(foldclosedend(11), 12, 'level 2 fold closed')

call vimtest#Quit()
