" Test highlighting after wrong settings with alternative settings.

let g:IndentConsistencyCop_IsFindBadMixEverywhere = 0
let g:IndentConsistencyCop_AltHighlighting = {'methods': 'Q', 'menu': 'Add wrong indents to &quickfix...'}
let g:IngoLibrary_ConfirmChoices = ['Wrong, use buffer settings (tabstop)', 'Add wrong indents to quickfix...']

edit test053.txt
IndentConsistencyCop

call vimtest#Quit()
