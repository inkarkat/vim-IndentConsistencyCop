" Test reconfiguring the context of folded consistent parts.

let g:IngoLibrary_ConfirmChoices = ['highlight', 'not buffer settings']

let g:indentconsistencycop_highlighting = substitute(g:indentconsistencycop_highlighting, 'f:3', 'f:1', '')

edit folded.txt
setlocal foldlevel=3
IndentConsistencyCop

call vimtest#StartTap()
call vimtap#Plan(4)
call vimtap#Is(foldclosedend(2), 8, 'above folded')
call vimtap#Is(foldclosedend(9), -1, 'start unfolded context')
call vimtap#Is(foldclosedend(11), -1, 'end unfolded context')
call vimtap#Is(foldclosedend(12), 15, 'below folded')

call vimtest#Quit()
