" Test reconfiguring no context of folded consistent parts.

let g:indentconsistencycop_choices = ['highlight', 'not buffer settings']

let g:indentconsistencycop_highlighting = substitute(g:indentconsistencycop_highlighting, 'f:3', 'f:0', '')

edit folded.txt
setlocal foldlevel=3
IndentConsistencyCop

call vimtest#StartTap()
call vimtap#Plan(3)
call vimtap#Is(foldclosedend(2), 9, 'above folded')
call vimtap#Is(foldclosedend(10), -1, 'unfolded actual inconsistency')
call vimtap#Is(foldclosedend(11), 15, 'below folded')

call vimtest#Quit()
