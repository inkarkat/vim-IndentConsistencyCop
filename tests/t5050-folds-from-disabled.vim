" Test highlighting folds away consistent parts from disabled folds.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

edit folded.txt
setlocal foldlevel=3 nofoldenable
IndentConsistencyCop

call vimtest#StartTap()
call vimtap#Plan(10)
call vimtap#Is(&l:foldlevel, 0, 'folds all closed')
call vimtap#Is(&l:foldenable, 1, 'folding enabled')
call vimtap#Is(foldclosedend(2), 6, 'above folded')
call vimtap#Is(foldclosedend(7), -1, 'start unfolded context')
call vimtap#Is(foldclosedend(13), -1, 'end unfolded context')
call vimtap#Is(foldclosedend(14), 15, 'below folded')

IndentConsistencyCopOff
call vimtap#Is(&l:foldlevel, 3, 'foldlevel restored')
call vimtap#Is(&l:foldenable, 0, 'folding disabled')
call vimtap#Is(foldclosedend(1), -1, 'above unfolded')
call vimtap#Is(foldclosedend(14), -1, 'below unfolded')

call vimtest#Quit()
