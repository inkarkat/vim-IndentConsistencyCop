" Test highlighting only with alternative settings.

let g:indentconsistencycop_highlighting = ''
let g:IndentConsistencyCop_AltHighlighting = {'methods': 'Q', 'menu': 'Add wrong indents to &quickfix...'}
let g:IngoLibrary_ConfirmChoices = ['Add wrong indents to quickfix...', 'not buffer settings']

edit test053.txt
IndentConsistencyCop
call vimtest#Quit()
