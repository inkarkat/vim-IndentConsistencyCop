" Test highlighting with alternative settings.

let g:IndentConsistencyCop_AltHighlighting = {'methods': 'Q', 'menu': 'Add wrong indents to &quickfix...'}
let g:IngoLibrary_ConfirmChoices = ['Add wrong indents to quickfix...', 'not buffer settings']

edit test053.txt
IndentConsistencyCop

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(map(getqflist(), 'v:val.lnum'), [13, 46, 47, 48, 49, 50, 51, 52], 'quickfix line numbers of inconsistent lines')

call vimtest#Quit()
